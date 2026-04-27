package com.github.lamarios.newsku.services;

import com.github.lamarios.newsku.Constants;
import com.github.lamarios.newsku.errors.NewskuException;
import com.github.lamarios.newsku.models.SyncStatus;
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
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

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

    private final ConcurrentHashMap<String, Boolean> articlesyncInProgress = new ConcurrentHashMap<>();

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
                recordSyncFailure(user, e);
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
        markSyncRunning(user);
        try {
            syncCategoriesStrict(user);
            syncFeedsStrict(user);
            // Articles + starred run async; flip to SUCCESS only after they finish.
            // Until then status stays RUNNING (cleared in syncArticlesAsync).
        } catch (NewskuException e) {
            recordSyncFailure(user, e);
            throw e;
        } catch (Exception e) {
            logger.error("On-demand GReader sync failed for user {}: {}", user.getUsername(), e.getMessage(), e);
            recordSyncFailure(user, e);
            String msg = e.getMessage() != null ? e.getMessage() : e.getClass().getSimpleName();
            throw new NewskuException("GReader sync failed: " + msg);
        }
    }

    /**
     * Fetches articles and starred items for the given user in a background thread
     * so the on-demand sync endpoint can return immediately after the feed list is ready.
     */
    @Async
    public void syncArticlesAsync(User user) {
        String userId = user.getId();
        if (articlesyncInProgress.putIfAbsent(userId, Boolean.TRUE) != null) {
            logger.info("Article sync already in progress for user {}, skipping duplicate trigger", user.getUsername());
            return;
        }
        // Each phase runs in its own try/catch (issue B21) so a failure in
        // syncArticles() no longer causes syncStarredItems() to be skipped.
        // Per-phase outcomes are logged with a structured "phase=" marker
        // so operators can slice logs per sync step.
        boolean anyPhaseFailed = false;
        Exception lastFailure = null;
        try {
            logger.info("Starting background article sync for user {}", user.getUsername());

            Exception articlesEx = runSyncPhase("articles", user, () -> syncArticles(user));
            Exception starredEx = runSyncPhase("starred", user, () -> syncStarredItems(user));
            if (articlesEx != null || starredEx != null) {
                anyPhaseFailed = true;
                lastFailure = starredEx != null ? starredEx : articlesEx;
            }

            logger.info("Background article sync complete for user {}", user.getUsername());
        } finally {
            articlesyncInProgress.remove(userId);
            if (anyPhaseFailed) {
                if (lastFailure != null) {
                    recordSyncFailure(user, lastFailure);
                }
                User reload = userRepository.findById(userId).orElse(user);
                reload.setLastSyncStatus(SyncStatus.PARTIAL);
                try {
                    userRepository.save(reload);
                } catch (Exception ignored) {
                }
            } else {
                recordSyncSuccess(user);
            }
        }
    }

    private Exception runSyncPhase(String phase, User user, Runnable task) {
        long start = System.currentTimeMillis();
        try {
            task.run();
            long durationMs = System.currentTimeMillis() - start;
            logger.info("Sync phase succeeded phase={} user={} durationMs={}",
                    phase, user.getUsername(), durationMs);
            return null;
        } catch (Exception e) {
            long durationMs = System.currentTimeMillis() - start;
            logger.error("Sync phase failed phase={} user={} durationMs={} error={}",
                    phase, user.getUsername(), durationMs, e.getMessage(), e);
            return e;
        }
    }

    // -----------------------------------------------------------------------
    // Per-user sync
    // -----------------------------------------------------------------------

    public void syncUser(User user) {
        logger.info("Starting GReader sync for user {}", user.getUsername());
        markSyncRunning(user);
        boolean anyFailure = false;
        try {
            syncCategories(user);
            syncFeeds(user);
            syncArticles(user);
            syncStarredItems(user);
        } catch (Exception e) {
            anyFailure = true;
            recordSyncFailure(user, e);
            throw e;
        } finally {
            if (!anyFailure) {
                recordSyncSuccess(user);
            }
        }
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
     * New items are persisted in batches via {@code saveAll} so Hibernate can
     * emit JDBC batch INSERTs (issue B16) instead of one round-trip per item.
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

            List<FeedItem> batch = new ArrayList<>(items.size());
            for (GReaderStreamItem item : items) {
                try {
                    FeedItem prepared = processArticle(item, user, clicks);
                    if (prepared != null) {
                        batch.add(prepared);
                        totalNew++;
                    }
                } catch (Exception e) {
                    logger.error("Failed to process GReader item {} for user {}: {}",
                            item.getId(), user.getUsername(), e.getMessage(), e);
                    saveFeedError(item, user, e);
                }
            }

            if (!batch.isEmpty()) {
                feedItemRepository.saveAll(batch);
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
            List<FeedItem> dirty = new ArrayList<>(feedItems.size());
            for (FeedItem feedItem : feedItems) {
                if (!feedItem.isSaved()) {
                    feedItem.setSaved(true);
                    dirty.add(feedItem);
                    markedSaved++;
                }
            }
            if (!dirty.isEmpty()) {
                // saveAll benefits from the batched UPDATE configured in
                // application.yml (issue B16).
                feedItemRepository.saveAll(dirty);
            }

            continuation = page.getContinuation();
        } while (continuation != null && !continuation.isBlank());

        if (markedSaved > 0) {
            logger.info("Marked {} items as saved from GReader starred stream for user {}", markedSaved, user.getUsername());
        }
    }

    /**
     * Prepares (and re-scores when necessary) a single GReader article. New
     * items are returned un-persisted so the caller can batch them via
     * {@code saveAll}. Re-scoring of pre-existing items is still persisted
     * individually because it flips a single row in-place.
     *
     * @return the new {@link FeedItem} to batch-persist, or {@code null} if
     *         the item already exists or its feed is not yet synced.
     */
    @Transactional
    protected FeedItem processArticle(GReaderStreamItem item, User user, List<com.github.lamarios.newsku.models.TagClickStat> clicks) {
        FeedItem existing = feedItemRepository.findByGReaderItemId(item.getId());
        if (existing != null) {
            rescoreIfNeeded(existing, item, user, clicks);
            return null;
        }

        String originStreamId = item.getOrigin() != null ? item.getOrigin().getStreamId() : null;
        Feed feed = originStreamId != null
                ? feedRepository.findByGReaderFeedIdAndUser(originStreamId, user)
                : null;

        if (feed == null) {
            logger.debug("Skipping article {} – feed '{}' not yet in newsku", item.getId(), originStreamId);
            return null;
        }

        String rawContent = item.resolveContent();
        String title = item.getTitle() != null ? item.getTitle() : "no title";
        String content = rawContent != null
                ? StringEscapeUtils.unescapeHtml4(HtmlUtils.getTextContent(rawContent))
                : "no content";

        var analysis = openaiService.processFeedItem(item.getId(), title, content, item.resolveTimestampMs(), user, clicks);

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
        feedItem.setTimeCreated(item.resolveTimestampMs());

        if (analysis.isPresent()) {
            feedItem.setImportance(analysis.get().importance());
            feedItem.setReasoning(analysis.get().reasoning());
            feedItem.setShortTitle(analysis.get().shortTitle());
            feedItem.setShortTeaser(analysis.get().shortTeaser());
            feedItem.setTags(analysis.get().tags().stream()
                    .map(String::toLowerCase)
                    .map(s -> s.replaceAll("[^a-zA-Z0-9 ]", ""))
                    .filter(s -> !s.isEmpty())
                    .toList());
        } else {
            // Persist the item even when AI analysis is unavailable (disabled,
            // quota exhausted, API down) so it still shows up in the feed.
            // importance defaults to 0; the ranking query filters by
            // user.minimumImportance, so items remain visible for users who
            // have not raised that threshold.
            logger.warn("AI analysis unavailable for GReader item {} (feed {}); persisting without score/tags",
                    item.getId(), feed.getId());
            feedItem.setTags(List.of());
        }

        return feedItem;
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------

    /**
     * Re-runs AI scoring for an article that was previously saved without AI analysis
     * (reasoning == null indicates the AI pipeline never ran for this article, e.g.
     * because the endpoint was misconfigured when the article was first imported).
     * Articles that already have a reasoning value are left untouched.
     */
    private void rescoreIfNeeded(FeedItem existing, GReaderStreamItem item, User user,
                                 List<com.github.lamarios.newsku.models.TagClickStat> clicks) {
        if (existing.getReasoning() != null) {
            return;
        }
        String rawContent = item.resolveContent();
        String title = item.getTitle() != null ? item.getTitle() : "no title";
        String content = rawContent != null
                ? StringEscapeUtils.unescapeHtml4(HtmlUtils.getTextContent(rawContent))
                : "no content";

        var analysis = openaiService.processFeedItem(
                item.getId(), title, content, item.resolveTimestampMs(), user, clicks);

        if (analysis.isEmpty()) {
            return;
        }

        var a = analysis.get();
        existing.setImportance(a.importance());
        existing.setReasoning(a.reasoning());
        existing.setShortTitle(a.shortTitle());
        existing.setShortTeaser(a.shortTeaser());
        existing.setTags(a.tags().stream()
                .map(String::toLowerCase)
                .map(s -> s.replaceAll("[^a-zA-Z0-9 ]", ""))
                .filter(s -> !s.isEmpty())
                .toList());
        feedItemRepository.save(existing);
        logger.info("Re-scored previously unscored article {} for user {}", existing.getId(), user.getUsername());
    }

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

    // -----------------------------------------------------------------------
    // Sync status tracking (F5)
    // -----------------------------------------------------------------------

    private void markSyncRunning(User user) {
        try {
            user.setLastSyncStatus(SyncStatus.RUNNING);
            user.setLastSyncErrorMessage(null);
            userRepository.save(user);
        } catch (Exception ex) {
            logger.warn("Could not record RUNNING sync status for user {}: {}", user.getUsername(), ex.getMessage());
        }
    }

    private void recordSyncSuccess(User user) {
        try {
            user.setLastSyncStatus(SyncStatus.SUCCESS);
            user.setLastSyncTime(System.currentTimeMillis());
            user.setLastSyncErrorMessage(null);
            userRepository.save(user);
        } catch (Exception ex) {
            logger.warn("Could not record SUCCESS sync status for user {}: {}", user.getUsername(), ex.getMessage());
        }
    }

    private void recordSyncFailure(User user, Exception cause) {
        try {
            user.setLastSyncStatus(SyncStatus.FAILED);
            user.setLastSyncTime(System.currentTimeMillis());
            user.setLastSyncErrorMessage(sanitiseErrorMessage(cause));
            userRepository.save(user);
        } catch (Exception ex) {
            logger.warn("Could not record FAILED sync status for user {}: {}", user.getUsername(), ex.getMessage());
        }
    }

    /**
     * Returns a short, user-presentable description of {@code cause} that does not
     * leak credentials, tokens or full URLs. Anything beyond the exception class
     * and a trimmed message is dropped.
     */
    private static String sanitiseErrorMessage(Exception cause) {
        if (cause == null) return "Unknown error";
        String raw = cause.getMessage();
        if (raw == null || raw.isBlank()) {
            return cause.getClass().getSimpleName();
        }
        String trimmed = raw.length() > 200 ? raw.substring(0, 200) + "…" : raw;
        return trimmed;
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
