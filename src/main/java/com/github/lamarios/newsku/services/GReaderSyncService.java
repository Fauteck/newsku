package com.github.lamarios.newsku.services;

import com.github.lamarios.newsku.Constants;
import com.github.lamarios.newsku.errors.NewskuException;
import com.github.lamarios.newsku.models.greader.GReaderStreamContents;
import com.github.lamarios.newsku.models.greader.GReaderStreamItem;
import com.github.lamarios.newsku.models.greader.GReaderSubscription;
import com.github.lamarios.newsku.models.greader.GReaderTag;
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
 * Synchronises data from a GReader-compatible backend into newsku.
 *
 * Sync order per user:
 *  1. Categories  (labels in GReader → FeedCategory in newsku)
 *  2. Feeds       (subscriptions in GReader → Feed in newsku)
 *  3. Articles    (unread stream → FeedItem + OpenAI scoring)
 *  4. Starred     (starred stream → mark matching FeedItems as saved)
 */
@Service
public class GReaderSyncService {

    private static final Logger logger = LogManager.getLogger();
    private static final long PROMPT_TAG_TIME_FRAME = 30L * 24 * 60 * 60 * 1000;

    private final GReaderApiService gReaderApiService;
    private final UserRepository userRepository;
    private final FeedRepository feedRepository;
    private final FeedCategoryRepository feedCategoryRepository;
    private final FeedItemRepository feedItemRepository;
    private final FeedErrorRepository feedErrorRepository;
    private final OpenaiService openaiService;
    private final ClickService clickService;
    private final PlatformTransactionManager transactionManager;

    @Autowired
    public GReaderSyncService(
            GReaderApiService gReaderApiService,
            UserRepository userRepository,
            FeedRepository feedRepository,
            FeedCategoryRepository feedCategoryRepository,
            FeedItemRepository feedItemRepository,
            FeedErrorRepository feedErrorRepository,
            OpenaiService openaiService,
            ClickService clickService,
            PlatformTransactionManager transactionManager) {
        this.gReaderApiService = gReaderApiService;
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

    /** Runs a full sync for every user with GReader credentials configured. */
    public void syncAll() {
        List<User> users = userRepository.findAll();
        for (User user : users) {
            if (!gReaderApiService.isCredentialsConfigured(user)) {
                logger.debug("GReader not configured for user {} – skipping", user.getUsername());
                continue;
            }
            try {
                syncUser(user);
            } catch (Exception e) {
                logger.error("GReader sync failed for user {}: {}", user.getUsername(), e.getMessage(), e);
            }
        }
    }

    // -----------------------------------------------------------------------
    // On-demand sync (triggered by UI)
    // -----------------------------------------------------------------------

    /**
     * Synchronises only categories and feeds (not articles) for a single user,
     * propagating any errors. Intended for UI-triggered syncs so the caller can
     * surface failures to the user.
     */
    @Transactional
    public void syncFeedsAndCategoriesOnDemand(User user) throws NewskuException {
        if (!gReaderApiService.isCredentialsConfigured(user)) {
            throw new NewskuException("GReader credentials not configured");
        }
        try {
            syncCategoriesStrict(user);
            syncFeedsStrict(user);
        } catch (NewskuException e) {
            throw e;
        } catch (Exception e) {
            logger.error("On-demand GReader sync failed for user {}: {}", user.getUsername(), e.getMessage(), e);
            String msg = e.getMessage() != null ? e.getMessage() : e.getClass().getSimpleName();
            throw new NewskuException("GReader sync failed: " + msg);
        }
    }

    // -----------------------------------------------------------------------
    // Per-user sync
    // -----------------------------------------------------------------------

    public void syncUser(User user) {
        logger.info("Starting GReader sync for user {}", user.getUsername());
        syncCategories(user);
        syncFeeds(user);
        syncArticles(user);
        syncStarredItems(user);
        logger.info("GReader sync complete for user {}", user.getUsername());
    }

    // -----------------------------------------------------------------------
    // Categories
    // -----------------------------------------------------------------------

    @Transactional
    public void syncCategories(User user) {
        List<GReaderTag> tags = gReaderApiService.getTags(user);
        applyCategorySync(user, tags);
    }

    /** Error-propagating variant for on-demand syncs. */
    @Transactional
    public void syncCategoriesStrict(User user) throws NewskuException {
        List<GReaderTag> tags = gReaderApiService.getTagsOrThrow(user);
        applyCategorySync(user, tags);
    }

    private void applyCategorySync(User user, List<GReaderTag> tags) {
        for (GReaderTag tag : tags) {
            FeedCategory existing = feedCategoryRepository.findByGReaderCategoryIdAndUser(tag.getId(), user);
            if (existing == null) {
                FeedCategory cat = new FeedCategory();
                cat.setId(UUID.randomUUID().toString());
                cat.setName(tag.getLabel());
                cat.setGReaderCategoryId(tag.getId());
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
        List<GReaderSubscription> subscriptions = gReaderApiService.getSubscriptions(user);
        applyFeedSync(user, subscriptions);
    }

    /** Error-propagating variant for on-demand syncs. */
    @Transactional
    public void syncFeedsStrict(User user) throws NewskuException {
        List<GReaderSubscription> subscriptions = gReaderApiService.getSubscriptionsOrThrow(user);
        applyFeedSync(user, subscriptions);
    }

    private void applyFeedSync(User user, List<GReaderSubscription> subscriptions) {
        for (GReaderSubscription sub : subscriptions) {
            Feed feed = feedRepository.findByGReaderFeedIdAndUser(sub.getId(), user);
            if (feed == null) {
                feed = new Feed();
                feed.setId(UUID.randomUUID().toString());
                feed.setGReaderFeedId(sub.getId());
                feed.setUser(user);
                logger.debug("Created feed '{}' for user {}", sub.getTitle(), user.getUsername());
            }
            feed.setName(sub.getTitle() != null ? sub.getTitle() : sub.getUrl());
            feed.setUrl(sub.getUrl() != null ? sub.getUrl() : stripFeedPrefix(sub.getId()));
            feed.setImage(sub.getIconUrl());

            if (sub.getCategories() != null && !sub.getCategories().isEmpty()) {
                String labelId = sub.getCategories().get(0).getId();
                FeedCategory cat = feedCategoryRepository.findByGReaderCategoryIdAndUser(labelId, user);
                feed.setCategory(cat);
            }

            feedRepository.save(feed);
        }
    }

    // -----------------------------------------------------------------------
    // Articles
    // -----------------------------------------------------------------------

    /**
     * Fetches all unread items from GReader and processes them through OpenAI scoring.
     * Pagination via the GReader continuation token.
     */
    public void syncArticles(User user) {
        var clicks = clickService.tagClicks(
                System.currentTimeMillis() - PROMPT_TAG_TIME_FRAME,
                System.currentTimeMillis(),
                user);

        String continuation = null;
        int totalNew = 0;

        do {
            GReaderStreamContents page = gReaderApiService.getUnreadItems(user, continuation);
            List<GReaderStreamItem> items = page.getItems();
            if (items == null || items.isEmpty()) break;

            for (GReaderStreamItem item : items) {
                try {
                    processArticle(item, user, clicks);
                    totalNew++;
                } catch (Exception e) {
                    logger.error("Failed to process GReader item {} for user {}: {}",
                            item.getId(), user.getUsername(), e.getMessage(), e);
                    saveFeedError(item, user, e);
                }
            }

            continuation = page.getContinuation();
        } while (continuation != null && !continuation.isBlank());

        logger.info("Processed {} new articles from GReader for user {}", totalNew, user.getUsername());
    }

    /**
     * Fetches all starred items from GReader and marks the corresponding local
     * FeedItems as saved (best-effort, does not unmark items no longer starred).
     */
    public void syncStarredItems(User user) {
        if (!gReaderApiService.isCredentialsConfigured(user)) return;

        List<Feed> feeds = feedRepository.getFeedsByUser(user);
        String continuation = null;
        int markedSaved = 0;

        do {
            GReaderStreamContents page = gReaderApiService.getStarredItems(user, continuation);
            List<GReaderStreamItem> items = page.getItems();
            if (items == null || items.isEmpty()) break;

            List<String> gReaderIds = items.stream().map(GReaderStreamItem::getId).toList();
            List<FeedItem> feedItems = feedItemRepository.findByGReaderItemIdInAndFeedIn(gReaderIds, feeds);
            for (FeedItem feedItem : feedItems) {
                if (!feedItem.isSaved()) {
                    feedItem.setSaved(true);
                    feedItemRepository.save(feedItem);
                    markedSaved++;
                }
            }

            continuation = page.getContinuation();
        } while (continuation != null && !continuation.isBlank());

        if (markedSaved > 0) {
            logger.info("Marked {} items as saved from GReader starred stream for user {}", markedSaved, user.getUsername());
        }
    }

    @Transactional
    protected void processArticle(GReaderStreamItem item, User user, List<com.github.lamarios.newsku.models.TagClickStat> clicks) {
        if (feedItemRepository.findByGReaderItemId(item.getId()) != null) {
            return;
        }

        String originStreamId = item.getOrigin() != null ? item.getOrigin().getStreamId() : null;
        Feed feed = originStreamId != null
                ? feedRepository.findByGReaderFeedIdAndUser(originStreamId, user)
                : null;

        if (feed == null) {
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
        feedItem.setGReaderItemId(item.getId());
        feedItem.setGuid(item.getId());
        feedItem.setFeed(feed);
        feedItem.setTitle(StringEscapeUtils.unescapeHtml4(HtmlUtils.getTextContent(title)));
        feedItem.setDescription(content);
        feedItem.setUrl(item.resolveUrl());
        feedItem.setImageUrl(imageUrl);
        feedItem.setImportance(analysis.get().importance());
        feedItem.setReasoning(analysis.get().reasoning());
        feedItem.setShortTitle(analysis.get().shortTitle());
        feedItem.setShortTeaser(analysis.get().shortTeaser());
        feedItem.setTimeCreated(item.resolveTimestampMs());
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

    private void saveFeedError(GReaderStreamItem item, User user, Exception e) {
        try {
            String originStreamId = item.getOrigin() != null ? item.getOrigin().getStreamId() : null;
            Feed feed = originStreamId != null
                    ? feedRepository.findByGReaderFeedIdAndUser(originStreamId, user)
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
        }
    }
}
