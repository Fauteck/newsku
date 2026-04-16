package com.github.lamarios.newsku.services;

import com.github.lamarios.newsku.Constants;
import com.github.lamarios.newsku.models.freshrss.FreshRssStreamContents;
import com.github.lamarios.newsku.models.freshrss.FreshRssStreamItem;
import com.github.lamarios.newsku.models.freshrss.FreshRssSubscription;
import com.github.lamarios.newsku.models.freshrss.FreshRssTag;
import com.github.lamarios.newsku.persistence.entities.Feed;
import com.github.lamarios.newsku.persistence.entities.FeedCategory;
import com.github.lamarios.newsku.persistence.entities.FeedError;
import com.github.lamarios.newsku.persistence.entities.FeedItem;
import com.github.lamarios.newsku.persistence.entities.User;
import com.github.lamarios.newsku.persistence.repositories.FeedCategoryRepository;
import com.github.lamarios.newsku.persistence.repositories.FeedErrorRepository;
import com.github.lamarios.newsku.persistence.repositories.FeedItemRepository;
import com.github.lamarios.newsku.persistence.repositories.FeedRepository;
import com.github.lamarios.newsku.persistence.repositories.UserRepository;
import com.github.lamarios.newsku.utils.HtmlUtils;
import org.apache.commons.lang3.exception.ExceptionUtils;
import org.apache.commons.text.StringEscapeUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jsoup.Jsoup;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

/**
 * Synchronises data from FreshRSS into newsku for all users that have
 * FreshRSS credentials configured.
 *
 * Sync order per user:
 *  1. Categories  (labels in FreshRSS → FeedCategory in newsku)
 *  2. Feeds       (subscriptions in FreshRSS → Feed in newsku)
 *  3. Articles    (unread stream → FeedItem + OpenAI scoring)
 */
@Service
public class FreshRssSyncService {

    private static final Logger logger = LogManager.getLogger();
    private static final long PROMPT_TAG_TIME_FRAME = 30L * 24 * 60 * 60 * 1000;

    private final FreshRssApiService freshRssApiService;
    private final UserRepository userRepository;
    private final FeedRepository feedRepository;
    private final FeedCategoryRepository feedCategoryRepository;
    private final FeedItemRepository feedItemRepository;
    private final FeedErrorRepository feedErrorRepository;
    private final OpenaiService openaiService;
    private final ClickService clickService;
    private final PlatformTransactionManager transactionManager;

    @Autowired
    public FreshRssSyncService(
            FreshRssApiService freshRssApiService,
            UserRepository userRepository,
            FeedRepository feedRepository,
            FeedCategoryRepository feedCategoryRepository,
            FeedItemRepository feedItemRepository,
            FeedErrorRepository feedErrorRepository,
            OpenaiService openaiService,
            ClickService clickService,
            PlatformTransactionManager transactionManager) {
        this.freshRssApiService = freshRssApiService;
        this.userRepository = userRepository;
        this.feedRepository = feedRepository;
        this.feedCategoryRepository = feedCategoryRepository;
        this.feedItemRepository = feedItemRepository;
        this.feedErrorRepository = feedErrorRepository;
        this.openaiService = openaiService;
        this.clickService = clickService;
        this.transactionManager = transactionManager;
    }

    // -----------------------------------------------------------------------
    // Entry point (called by ScheduleService)
    // -----------------------------------------------------------------------

    /**
     * Runs a full sync for every user that has FreshRSS credentials configured.
     */
    public void syncAll() {
        if (!freshRssApiService.isCredentialsConfigured()) {
            logger.debug("FreshRSS not configured (FRESHRSS_URL / FRESHRSS_USERNAME / FRESHRSS_API_PASSWORD not set) – skipping sync");
            return;
        }
        List<User> users = userRepository.findAll();
        for (User user : users) {
            try {
                syncUser(user);
            } catch (Exception e) {
                logger.error("FreshRSS sync failed for user {}: {}", user.getUsername(), e.getMessage(), e);
            }
        }
    }

    // -----------------------------------------------------------------------
    // Per-user sync
    // -----------------------------------------------------------------------

    public void syncUser(User user) {
        logger.info("Starting FreshRSS sync for user {}", user.getUsername());
        syncCategories(user);
        syncFeeds(user);
        syncArticles(user);
        logger.info("FreshRSS sync complete for user {}", user.getUsername());
    }

    // -----------------------------------------------------------------------
    // Categories
    // -----------------------------------------------------------------------

    @Transactional
    public void syncCategories(User user) {
        List<FreshRssTag> tags = freshRssApiService.getTags(user);
        for (FreshRssTag tag : tags) {
            FeedCategory existing = feedCategoryRepository.findByFreshRssCategoryIdAndUser(tag.getId(), user);
            if (existing == null) {
                FeedCategory cat = new FeedCategory();
                cat.setId(UUID.randomUUID().toString());
                cat.setName(tag.getLabel());
                cat.setFreshRssCategoryId(tag.getId());
                cat.setUser(user);
                feedCategoryRepository.save(cat);
                logger.debug("Created category '{}' for user {}", tag.getLabel(), user.getUsername());
            } else if (!tag.getLabel().equals(existing.getName())) {
                existing.setName(tag.getLabel());
                feedCategoryRepository.save(existing);
            }
        }
    }

    // -----------------------------------------------------------------------
    // Feeds (subscriptions)
    // -----------------------------------------------------------------------

    @Transactional
    public void syncFeeds(User user) {
        List<FreshRssSubscription> subscriptions = freshRssApiService.getSubscriptions(user);
        for (FreshRssSubscription sub : subscriptions) {
            Feed feed = feedRepository.findByFreshRssFeedIdAndUser(sub.getId(), user);
            if (feed == null) {
                feed = new Feed();
                feed.setId(UUID.randomUUID().toString());
                feed.setFreshRssFeedId(sub.getId());
                feed.setUser(user);
                logger.debug("Created feed '{}' for user {}", sub.getTitle(), user.getUsername());
            }
            // Always refresh metadata from FreshRSS
            feed.setName(sub.getTitle() != null ? sub.getTitle() : sub.getUrl());
            feed.setUrl(sub.getUrl() != null ? sub.getUrl() : stripFeedPrefix(sub.getId()));
            feed.setImage(sub.getIconUrl());

            // Assign category if present
            if (sub.getCategories() != null && !sub.getCategories().isEmpty()) {
                String labelId = sub.getCategories().get(0).getId();
                FeedCategory cat = feedCategoryRepository.findByFreshRssCategoryIdAndUser(labelId, user);
                feed.setCategory(cat);
            }

            feedRepository.save(feed);
        }
    }

    // -----------------------------------------------------------------------
    // Articles
    // -----------------------------------------------------------------------

    /**
     * Fetches all unread items from FreshRSS for the given user and processes them
     * through OpenAI scoring.  Pagination via the GReader continuation token.
     */
    public void syncArticles(User user) {
        var clicks = clickService.tagClicks(
                System.currentTimeMillis() - PROMPT_TAG_TIME_FRAME,
                System.currentTimeMillis(),
                user);

        String continuation = null;
        int totalNew = 0;

        do {
            FreshRssStreamContents page = freshRssApiService.getUnreadItems(user, continuation);
            List<FreshRssStreamItem> items = page.getItems();
            if (items == null || items.isEmpty()) break;

            for (FreshRssStreamItem item : items) {
                try {
                    processArticle(item, user, clicks);
                    totalNew++;
                } catch (Exception e) {
                    logger.error("Failed to process FreshRSS item {} for user {}: {}",
                            item.getId(), user.getUsername(), e.getMessage(), e);
                    saveFeedError(item, user, e);
                }
            }

            continuation = page.getContinuation();
        } while (continuation != null && !continuation.isBlank());

        logger.info("Processed {} new articles from FreshRSS for user {}", totalNew, user.getUsername());
    }

    @Transactional
    protected void processArticle(FreshRssStreamItem item, User user, List<com.github.lamarios.newsku.models.TagClickStat> clicks) {
        // Skip if already stored
        if (feedItemRepository.findByFreshRssItemId(item.getId()) != null) {
            return;
        }

        // Find the feed this article belongs to
        String originStreamId = item.getOrigin() != null ? item.getOrigin().getStreamId() : null;
        Feed feed = originStreamId != null
                ? feedRepository.findByFreshRssFeedIdAndUser(originStreamId, user)
                : null;

        if (feed == null) {
            // Feed not synced yet – skip; next syncFeeds() call will create it
            logger.debug("Skipping article {} – feed '{}' not yet in newsku", item.getId(), originStreamId);
            return;
        }

        String rawContent = item.resolveContent();
        String title = item.getTitle() != null ? item.getTitle() : "no title";
        String content = rawContent != null
                ? StringEscapeUtils.unescapeHtml4(HtmlUtils.getTextContent(rawContent))
                : "no content";

        var analysis = openaiService.processFeedItem(item.getId(), title, content, user, clicks);
        if (analysis.isEmpty()) return;

        String imageUrl = item.resolveImageUrl();
        if (imageUrl == null && rawContent != null) {
            imageUrl = extractImageFromHtml(rawContent);
        }
        if (imageUrl == null) {
            imageUrl = extractOgImageFromUrl(item.resolveUrl());
        }

        FeedItem feedItem = new FeedItem();
        feedItem.setId(UUID.randomUUID().toString());
        feedItem.setFreshRssItemId(item.getId());
        feedItem.setGuid(item.getId());  // use FreshRSS ID also as guid for deduplication
        feedItem.setFeed(feed);
        feedItem.setTitle(StringEscapeUtils.unescapeHtml4(HtmlUtils.getTextContent(title)));
        feedItem.setDescription(content);
        feedItem.setUrl(item.resolveUrl());
        feedItem.setImageUrl(imageUrl);
        feedItem.setImportance(analysis.get().importance());
        feedItem.setReasoning(analysis.get().reasoning());
        feedItem.setShortTitle(analysis.get().shortTitle());
        feedItem.setShortTeaser(analysis.get().shortTeaser());
        feedItem.setTimeCreated(item.getPublished() > 0
                ? item.getPublished() * 1000L   // FreshRSS returns seconds, newsku uses ms
                : System.currentTimeMillis());
        feedItem.setTags(analysis.get().tags().stream()
                .map(String::toLowerCase)
                .map(s -> s.replaceAll("[^a-zA-Z0-9 ]", ""))
                .filter(s -> !s.isEmpty())
                .toList());

        feedItemRepository.save(feedItem);
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------

    /** Strips the "feed/" prefix from a GReader stream ID to get the raw URL. */
    private static String stripFeedPrefix(String streamId) {
        if (streamId != null && streamId.startsWith("feed/")) {
            return streamId.substring(5);
        }
        return streamId;
    }

    private static String extractImageFromHtml(String html) {
        if (html == null) return null;
        String src = Jsoup.parse(html).getElementsByTag("img").attr("src");
        return src.isBlank() ? null : src;
    }

    private static final List<String> OG_IMAGE_SELECTORS = List.of(
            "meta[property=og:image]",
            "meta[name=og:image]",
            "meta[property=twitter:image]",
            "meta[name=twitter:image]");

    private static String extractOgImageFromUrl(String url) {
        if (url == null || url.isBlank()) return null;
        try {
            var doc = Jsoup.connect(url)
                    .userAgent(Constants.USER_AGENT)
                    .timeout(5000)
                    .get();
            for (String selector : OG_IMAGE_SELECTORS) {
                String content = doc.select(selector).attr("content");
                if (!content.isBlank()) return content;
            }
        } catch (Exception e) {
            logger.debug("og:image fetch failed for {}: {}", url, e.getMessage());
        }
        return null;
    }

    private void saveFeedError(FreshRssStreamItem item, User user, Exception e) {
        try {
            // Find the feed to attach the error to (best-effort)
            String originStreamId = item.getOrigin() != null ? item.getOrigin().getStreamId() : null;
            Feed feed = originStreamId != null
                    ? feedRepository.findByFreshRssFeedIdAndUser(originStreamId, user)
                    : null;
            if (feed == null) return;

            FeedError error = new FeedError();
            error.setId(UUID.randomUUID().toString());
            error.setTimeCreated(System.currentTimeMillis());
            error.setFeed(feed);
            error.setMessage(ExceptionUtils.getMessage(e));
            error.setError(ExceptionUtils.getStackTrace(e));
            error.setUrl(item.resolveUrl());
            feedErrorRepository.save(error);
        } catch (Exception ignored) {
            // error saving is best-effort
        }
    }
}
