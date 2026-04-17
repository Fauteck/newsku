package com.github.lamarios.newsku.services;

import com.apptasticsoftware.rssreader.Enclosure;
import com.apptasticsoftware.rssreader.Item;
import com.github.lamarios.newsku.persistence.entities.*;
import com.github.lamarios.newsku.persistence.repositories.*;
import com.github.lamarios.newsku.utils.HtmlUtils;
import com.github.lamarios.newsku.utils.TransactionHelper;
import jakarta.persistence.EntityManager;
import org.apache.commons.lang3.exception.ExceptionUtils;
import org.apache.commons.text.StringEscapeUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jetbrains.annotations.NotNull;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Transactional;

import java.sql.SQLException;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@Service
public class FeedItemService {
    private final static Logger logger = LogManager.getLogger();
    private final static long PROMPT_TAG_TIME_FRAME = 30 * 24 * 60 * 60 * 1000L; // 30 days
    private final FeedService feedService;
    private final ExecutorService exec = Executors.newSingleThreadExecutor();


    private final FeedItemRepository feedItemRepository;

    private final PlatformTransactionManager transactionManager;
    private final OpenaiService openaiService;
    private final UserService userService;
    private final EntityManager entityManager;
    private final FeedRepository feedRepository;
    private final FeedErrorRepository feedErrorRepository;
    private final FeedClicksRepository feedClicksRepository;
    private final TagClicksRepository tagClicksRepository;
    private final ClickService clickService;
    private final GReaderApiService gReaderApiService;

    @Autowired
    public FeedItemService(FeedItemRepository feedItemRepository, PlatformTransactionManager transactionManager, OpenaiService openaiService, FeedService feedService, UserService userService, EntityManager entityManager, FeedRepository feedRepository, FeedErrorRepository feedErrorRepository, FeedClicksRepository feedClicksRepository, TagClicksRepository tagClicksRepository, ClickService clickService, GReaderApiService gReaderApiService) {
        this.feedItemRepository = feedItemRepository;
        this.transactionManager = transactionManager;
        this.openaiService = openaiService;
        this.feedService = feedService;
        this.userService = userService;
        this.entityManager = entityManager;
        this.feedRepository = feedRepository;
        this.feedErrorRepository = feedErrorRepository;
        this.feedClicksRepository = feedClicksRepository;
        this.tagClicksRepository = tagClicksRepository;
        this.clickService = clickService;
        this.gReaderApiService = gReaderApiService;
    }

    public void refreshFeed(Feed feed) {
        exec.submit(() -> refreshFeedWorker(feed));
    }

    public void refreshFeedWorker(Feed feed) {
        int errors = 0;
        try {
            logger.info("Refreshing feed {}", feed.getId());

            List<Item> items = FeedService.DEFAULT_READER.read(feed.getUrl())
                    .sorted()
                    .filter(item -> item.getGuid().isPresent())
                    .toList();

            for (Item item : items) {
                try {
                    TransactionHelper.doInNewTransaction(transactionManager, false, () -> {


                        if (item.getGuid().isEmpty()) {
                            return;
                        }

                        try {
                            var existingFeed = feedItemRepository.getFirstByGuidAndFeed(item.getGuid().get(), feed);

                            Optional<String> image = item.getEnclosure()
                                    .filter(e -> e.getType().contains("image"))
                                    .map(Enclosure::getUrl);

                            String imageUrl = image.orElse(getImageUrl(item));

                            if (existingFeed != null) {
                                logger.info("Feed {} already processed", item.getGuid().get());
                                return;
                            }

                            var clicks = clickService.tagClicks(System.currentTimeMillis() - PROMPT_TAG_TIME_FRAME, System.currentTimeMillis(), feed.getUser());

                            var analysis = openaiService.processFeedItem(item, feed.getUser(), clicks);
                            if (analysis.isPresent()) {

                                FeedItem newItem = new FeedItem();
                                newItem.setId(UUID.randomUUID().toString());
                                newItem.setFeed(feed);
                                newItem.setUrl(item.getLink().orElse(null));
                                newItem.setGuid(item.getGuid().get());
                                newItem.setDescription(item.getDescription()
                                        .map(StringEscapeUtils::unescapeHtml4)
                                        .map(HtmlUtils::getTextContent)
                                        .orElse(null));
                                newItem.setTitle(item.getTitle().map(StringEscapeUtils::unescapeHtml4)
                                        .map(HtmlUtils::getTextContent)
                                        .orElse(null));
                                newItem.setContent(item.getContent()
                                        .map(StringEscapeUtils::unescapeHtml4)
                                        .map(HtmlUtils::getTextContent)
                                        .orElse(null));
                                newItem.setImportance(analysis.get().importance());
                                newItem.setReasoning(analysis.get().reasoning());
                                newItem.setShortTitle(analysis.get().shortTitle());
                                newItem.setShortTeaser(analysis.get().shortTeaser());
                                newItem.setImageUrl(imageUrl);
                                newItem.setTimeCreated(item.getPubDateAsZonedDateTime()
                                        .map(zonedDateTime -> zonedDateTime.toInstant().toEpochMilli())
                                        .orElse(System.currentTimeMillis()));
                                newItem.setTags(analysis.get()
                                        .tags()
                                        .stream()
                                        .map(String::toLowerCase)
                                        .map(s -> s.replaceAll("[^a-zA-Z0-9 ]", ""))
                                        .filter(s -> !s.isEmpty())
                                        .toList());

                                feedItemRepository.save(newItem);
                            }
                        } catch (Exception e) {
                            logger.error("Couldn't parse feed item: {}", item.getGuid(), e);
                            throw e;
                        }
                    });
                } catch (Exception e) {
                    logger.error("Couldn't parse feed item: {}, top level catch", item.getGuid(), e);
                    FeedError error = new FeedError();
                    error.setId(UUID.randomUUID().toString());
                    error.setTimeCreated(System.currentTimeMillis());
                    error.setFeed(feed);
                    error.setMessage(ExceptionUtils.getMessage(e));
                    error.setError(ExceptionUtils.getStackTrace(e));
                    if (item.getLink().isPresent()) {
                        error.setUrl(item.getLink().get());
                    }

                    feedErrorRepository.save(error);

                    errors++;
                }
            }
        } catch (Exception e) {
            logger.error("Couldn't parse feed: {}", feed.getUrl(), e);

            FeedError error = new FeedError();
            error.setId(UUID.randomUUID().toString());
            error.setTimeCreated(System.currentTimeMillis());
            error.setFeed(feed);
            error.setMessage(ExceptionUtils.getMessage(e));
            error.setError(ExceptionUtils.getStackTrace(e));
            feedErrorRepository.save(error);
            errors++;
        }

        feed.setLastRefreshErrors(errors);
        feedRepository.save(feed);
    }

    private String getImageUrl(Item item) {
        String imageUrl = null;
        if (item.getDescription().isPresent()) {
            Document doc = Jsoup.parse(item.getDescription().get());
            imageUrl = doc.getElementsByTag("img").attr("src");
        }

        if ((imageUrl == null || imageUrl.isBlank()) && item.getContent().isPresent()) {
            Document doc = Jsoup.parse(item.getContent().get());
            imageUrl = doc.getElementsByTag("img").attr("src");
        }
        return Optional.ofNullable(imageUrl).filter(s -> !s.isBlank()).orElse(null);

    }

    @Transactional
    public void itemClicked(String id) {
        User user = userService.getCurrentUser();
        List<Feed> feeds = feedRepository.getFeedsByUser(user);
        FeedItem feedItem = feedItemRepository.getFirstByIdAndFeedIn(id, feeds);

        if (feedItem == null) {
            return;
        }

        FeedClick feedClick = new FeedClick();
        feedClick.setId(UUID.randomUUID().toString());
        feedClick.setFeed(feedItem.getFeed());
        feedClick.setTimeCreated(System.currentTimeMillis());
        feedClicksRepository.save(feedClick);

        for (String tag : feedItem.getTags()) {
            TagClick tagClick = new TagClick();
            tagClick.setId(UUID.randomUUID().toString());
            tagClick.setTag(tag);
            tagClick.setTimeCreated(System.currentTimeMillis());
            tagClick.setUser(user);
            tagClicksRepository.save(tagClick);
        }


    }

    @Transactional(readOnly = true)
    public Page<@NotNull FeedItem> getItems(Long from, Long to, int page, int pageSize, Integer minimumImportanceOverride) {
        return getItems(from, to, page, pageSize, minimumImportanceOverride, null, null, null);
    }

    @Transactional(readOnly = true)
    public Page<@NotNull FeedItem> getItems(Long from, Long to, int page, int pageSize, Integer minimumImportanceOverride, String sort, String feedId, String categoryId) {

        List<Feed> feeds = feedService.getFeeds();
        var user = userService.getCurrentUser();
        int minImportance = minimumImportanceOverride != null ? minimumImportanceOverride : user.getMinimumImportance();

        if (feedId != null && !feedId.isBlank()) {
            feeds = feeds.stream().filter(f -> feedId.equals(f.getId())).toList();
        } else if (categoryId != null && !categoryId.isBlank()) {
            feeds = feeds.stream()
                    .filter(f -> f.getCategory() != null && categoryId.equals(f.getCategory().getId()))
                    .toList();
        }

        if (feeds.isEmpty()) {
            return Page.empty(PageRequest.of(page, pageSize));
        }

        Sort sortOrder;
        if ("chronological".equalsIgnoreCase(sort)) {
            sortOrder = Sort.by(new Sort.Order(Sort.Direction.DESC, "timeCreated"));
        } else {
            sortOrder = Sort.by(List.of(
                    new Sort.Order(Sort.Direction.DESC, "importance"),
                    new Sort.Order(Sort.Direction.DESC, "timeCreated")));
        }

        return feedItemRepository.findallByTimeAndFeeds(minImportance, from, to, feeds, PageRequest.of(page, pageSize, sortOrder));
    }

    @Transactional(readOnly = true)
    public Page<@NotNull FeedItem> getPublicItems(com.github.lamarios.newsku.persistence.entities.MagazineTab tab, long from, long to, int page, int pageSize) {
        var user = tab.getUser();
        List<Feed> feeds = feedRepository.getFeedsByUser(user);
        int minImportance = tab.getMinimumImportance() != null ? tab.getMinimumImportance() : user.getMinimumImportance();

        return feedItemRepository.findallByTimeAndFeeds(minImportance, from, to, feeds, PageRequest.of(page, pageSize, Sort.by(List.of(new Sort.Order(Sort.Direction.DESC, "importance"), new Sort.Order(Sort.Direction.DESC, "timeCreated")))));
    }

    @Transactional(readOnly = true)
    public List<FeedItem> search(String query, int page, int pageSize) {
        var feeds = feedRepository.getFeedsByUser(userService.getCurrentUser());
        return entityManager.createNativeQuery("select * from feed_items where search_terms @@ websearch_to_tsquery(:textQuery) and feed_id in :feeds limit :pageSize offset :page", FeedItem.class)
                .setParameter("textQuery", query)
                .setParameter("feeds", feeds.stream().map(Feed::getId).toList())
                .setParameter("pageSize", pageSize)
                .setParameter("page", page * pageSize)
                .getResultList();
    }

    @Transactional(readOnly = true)
    public FeedItem getItem(String id) throws SQLException {

        List<Feed> feeds = feedService.getFeeds();

        return feedItemRepository.findFirstByIdAndFeedIn(id, feeds).stream().findFirst().orElse(null);
    }

    @Transactional
    public boolean readItems(List<String> ids) {
        User user = userService.getCurrentUser();
        var feeds = feedRepository.getFeedsByUser(user);
        var items = feedItemRepository.findByIdInAndFeedIn(ids, feeds);

        items.forEach(feedItem -> feedItem.setRead(true));
        feedItemRepository.saveAll(items);

        // Sync read-status back to GReader (best-effort, non-blocking)
        List<String> gReaderIds = items.stream()
                .map(FeedItem::getGReaderItemId)
                .filter(fid -> fid != null && !fid.isBlank())
                .toList();
        if (!gReaderIds.isEmpty()) {
            try {
                gReaderApiService.markAsRead(user, gReaderIds);
            } catch (Exception e) {
                logger.warn("Could not sync read-status to GReader for user {}: {}", user.getUsername(), e.getMessage());
            }
        }

        return true;
    }

    @Transactional
    public FeedItem toggleSaved(String id) {
        User user = userService.getCurrentUser();
        var feeds = feedRepository.getFeedsByUser(user);
        var item = feedItemRepository.getFirstByIdAndFeedIn(id, feeds);

        if (item == null) {
            return null;
        }

        item.setSaved(!item.isSaved());
        feedItemRepository.save(item);

        // Sync starred status back to GReader (best-effort)
        String gReaderItemId = item.getGReaderItemId();
        if (gReaderItemId != null && !gReaderItemId.isBlank()) {
            try {
                gReaderApiService.markAsStarred(user, List.of(gReaderItemId), item.isSaved());
            } catch (Exception e) {
                logger.warn("Could not sync starred status to GReader for user {}: {}", user.getUsername(), e.getMessage());
            }
        }

        return item;
    }

    @Transactional(readOnly = true)
    public List<FeedItem> getSavedItems() {
        var feeds = feedRepository.getFeedsByUser(userService.getCurrentUser());
        return feedItemRepository.findBySavedTrueAndFeedIn(feeds);
    }
}
