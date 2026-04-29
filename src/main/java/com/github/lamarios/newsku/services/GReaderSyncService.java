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
import org.springframework.context.annotation.Lazy;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicBoolean;

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

    /**
     * Cron-level guard so that overlapping ticks of {@link #syncAll()} do not pile
     * up when a previous run is still draining a slow AI backend. Without this,
     * a 20-min cron interval combined with multi-hour syncs would trigger
     * concurrent {@code syncUser()} calls per user and race on
     * {@code User.lastSyncStatus}.
     */
    private final AtomicBoolean syncAllInProgress = new AtomicBoolean(false);

    private final GReaderApiService gReaderApiService;
    private final UserRepository userRepository;
    private final FeedRepository feedRepository;
    private final FeedCategoryRepository feedCategoryRepository;
    private final FeedItemRepository feedItemRepository;
    private final FeedErrorRepository feedErrorRepository;
    private final OpenaiService openaiService;
    private final ClickService clickService;
    private final PlatformTransactionManager transactionManager;

    /**
     * Self-reference used to invoke {@link #enrichBatchAsync(List, User)} via
     * the Spring proxy so the {@code @Async} annotation actually dispatches to
     * the task executor. Direct {@code this.enrichBatchAsync(...)} calls would
     * bypass the proxy and run the enrichment on the calling thread.
     */
    @Autowired
    @Lazy
    private GReaderSyncService self;

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
        if (!syncAllInProgress.compareAndSet(false, true)) {
            logger.warn("syncAll already running — skipping this tick");
            return;
        }
        try {
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
        } finally {
            syncAllInProgress.set(false);
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
        int itemsAdded = 0;
        int itemsUpdated = 0;
        try {
            logger.info("Starting background article sync for user {}", user.getUsername());

            PhaseResult articles = runCountingPhase("articles", user, () -> syncArticles(user));
            PhaseResult starred = runCountingPhase("starred", user, () -> syncStarredItems(user));
            itemsAdded = articles.count;
            itemsUpdated = starred.count;
            if (articles.failure != null || starred.failure != null) {
                anyPhaseFailed = true;
                lastFailure = starred.failure != null ? starred.failure : articles.failure;
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
                reload.setLastSyncItemsAdded(itemsAdded);
                reload.setLastSyncItemsUpdated(itemsUpdated);
                try {
                    userRepository.save(reload);
                } catch (Exception ignored) {
                }
            } else {
                recordSyncSuccess(user, itemsAdded, itemsUpdated);
            }
        }
    }

    private record PhaseResult(int count, Exception failure) {
    }

    private PhaseResult runCountingPhase(String phase, User user, java.util.function.IntSupplier task) {
        long start = System.currentTimeMillis();
        try {
            int count = task.getAsInt();
            long durationMs = System.currentTimeMillis() - start;
            logger.info("Sync phase succeeded phase={} user={} durationMs={} count={}",
                    phase, user.getUsername(), durationMs, count);
            return new PhaseResult(count, null);
        } catch (Exception e) {
            long durationMs = System.currentTimeMillis() - start;
            logger.error("Sync phase failed phase={} user={} durationMs={} error={}",
                    phase, user.getUsername(), durationMs, e.getMessage(), e);
            return new PhaseResult(0, e);
        }
    }

    // -----------------------------------------------------------------------
    // Per-user sync
    // -----------------------------------------------------------------------

    public void syncUser(User user) {
        logger.info("Starting GReader sync for user {}", user.getUsername());
        markSyncRunning(user);
        boolean anyFailure = false;
        int itemsAdded = 0;
        int itemsUpdated = 0;
        try {
            syncCategories(user);
            syncFeeds(user);
            itemsAdded = syncArticles(user);
            itemsUpdated = syncStarredItems(user);
        } catch (Exception e) {
            anyFailure = true;
            recordSyncFailure(user, e);
            throw e;
        } finally {
            if (!anyFailure) {
                recordSyncSuccess(user, itemsAdded, itemsUpdated);
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
     * Fetches all unread items from GReader and persists them.
     *
     * <p>Items are saved <strong>without</strong> AI analysis first so they
     * become visible in the feed/magazine view within seconds, regardless of
     * how slow the AI backend is. After each page commits, AI enrichment
     * (relevance score, tags, short title/teaser) runs asynchronously via
     * {@link #enrichBatchAsync(List, User)} and back-fills the rows in place.
     *
     * <p>Pagination via the GReader continuation token. New items are persisted
     * in batches via {@code saveAll} so Hibernate can emit JDBC batch INSERTs
     * (issue B16) instead of one round-trip per item.
     */
    public int syncArticles(User user) {
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
            List<String> existingUnscored = new ArrayList<>();
            for (GReaderStreamItem item : items) {
                try {
                    FeedItem prepared = processArticle(item, user, existingUnscored);
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

            List<String> enrichmentIds = new ArrayList<>(batch.size() + existingUnscored.size());
            for (FeedItem fi : batch) {
                enrichmentIds.add(fi.getId());
            }
            enrichmentIds.addAll(existingUnscored);
            if (!enrichmentIds.isEmpty()) {
                // Falls back to a direct call when the Spring proxy is not
                // wired (e.g. plain-JUnit unit tests instantiating this
                // service manually). In production the @Lazy self-reference
                // dispatches to the @Async task executor.
                GReaderSyncService target = self != null ? self : this;
                target.enrichBatchAsync(enrichmentIds, user);
            }

            continuation = page.getContinuation();
        } while (continuation != null && !continuation.isBlank());

        logger.info("Persisted {} new articles from GReader for user {} (AI enrichment runs in background)",
                totalNew, user.getUsername());
        return totalNew;
    }

    /**
     * Fetches all starred items from GReader and marks the corresponding local
     * FeedItems as saved (best-effort, does not unmark items no longer starred).
     *
     * @return the number of items that were newly marked as saved on this run
     */
    public int syncStarredItems(User user) {
        if (!gReaderApiService.isCredentialsConfigured(user)) return 0;

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
        return markedSaved;
    }

    /**
     * Prepares a single GReader article for persistence. The returned item is
     * un-persisted so the caller can batch them via {@code saveAll}. AI
     * scoring is intentionally NOT performed here — items are saved without
     * importance/reasoning/short title/teaser/tags first so they show up in
     * the feed view immediately, and {@link #enrichBatchAsync(List, User)}
     * back-fills those fields asynchronously. importance defaults to 0; the
     * ranking query filters by {@code user.minimumImportance}, so items
     * remain visible for users who have not raised that threshold.
     *
     * @return the new {@link FeedItem} to batch-persist, or {@code null} if
     *         the item already exists or its feed is not yet synced.
     */
    @Transactional
    protected FeedItem processArticle(GReaderStreamItem item, User user, List<String> existingUnscored) {
        FeedItem existing = feedItemRepository.findByGReaderItemId(item.getId());
        if (existing != null) {
            if (existing.getReasoning() == null) {
                existingUnscored.add(existing.getId());
            }
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
        feedItem.setTags(List.of());
        return feedItem;
    }

    /**
     * Runs AI enrichment for the given persisted {@link FeedItem} ids in a
     * background thread. Items whose {@code reasoning} field is already
     * populated are skipped (idempotent re-runs are safe). When the AI
     * service is unavailable, in cooldown, over quota, or simply fails, the
     * row is left as-is and a future sync will retry.
     */
    @Async
    public void enrichBatchAsync(List<String> feedItemIds, User user) {
        if (feedItemIds == null || feedItemIds.isEmpty()) return;
        var clicks = clickService.tagClicks(
                System.currentTimeMillis() - PROMPT_TAG_TIME_FRAME,
                System.currentTimeMillis(),
                user);
        for (String id : feedItemIds) {
            try {
                feedItemRepository.findById(id).ifPresent(item -> enrichSingle(item, user, clicks));
            } catch (Exception e) {
                logger.warn("AI enrichment failed for item {}: {}", id, e.getMessage());
            }
        }
    }

    private void enrichSingle(FeedItem item, User user, List<com.github.lamarios.newsku.models.TagClickStat> clicks) {
        if (item.getReasoning() != null) {
            return;
        }
        var analysis = openaiService.processFeedItem(
                item.getGReaderItemId() != null ? item.getGReaderItemId() : item.getId(),
                item.getTitle() != null ? item.getTitle() : "no title",
                item.getDescription() != null ? item.getDescription() : "no content",
                item.getTimeCreated(),
                user,
                clicks);
        if (analysis.isEmpty()) {
            return;
        }
        applyAnalysis(item, analysis.get());
        feedItemRepository.save(item);
    }

    private static void applyAnalysis(FeedItem item, com.github.lamarios.newsku.models.OpenAiFeedResponse a) {
        item.setImportance(a.importance());
        item.setReasoning(a.reasoning());
        item.setShortTitle(a.shortTitle());
        item.setShortTeaser(a.shortTeaser());
        item.setTags(a.tags().stream()
                .map(String::toLowerCase)
                .map(s -> s.replaceAll("[^a-zA-Z0-9 ]", ""))
                .filter(s -> !s.isEmpty())
                .toList());
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

    private void recordSyncSuccess(User user, int itemsAdded, int itemsUpdated) {
        try {
            user.setLastSyncStatus(SyncStatus.SUCCESS);
            user.setLastSyncTime(System.currentTimeMillis());
            user.setLastSyncErrorMessage(null);
            user.setLastSyncItemsAdded(itemsAdded);
            user.setLastSyncItemsUpdated(itemsUpdated);
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
