package com.github.lamarios.newsku.services;

import com.apptasticsoftware.rssreader.Enclosure;
import com.apptasticsoftware.rssreader.Item;
import com.apptasticsoftware.rssreader.RssReader;
import com.apptasticsoftware.rssreader.filter.InvalidXmlCharacterFilter;
import com.github.lamarios.newsku.persistence.entities.Feed;
import com.github.lamarios.newsku.persistence.entities.FeedError;
import com.github.lamarios.newsku.persistence.entities.FeedItem;
import com.github.lamarios.newsku.persistence.repositories.FeedErrorRepository;
import com.github.lamarios.newsku.persistence.repositories.FeedItemRepository;
import com.github.lamarios.newsku.persistence.repositories.FeedRepository;
import com.github.lamarios.newsku.utils.TransactionHelper;
import jakarta.persistence.EntityManager;
import org.apache.commons.lang3.exception.ExceptionUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
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
    private final FeedService feedService;
    private final ExecutorService exec = Executors.newSingleThreadExecutor();

    private final FeedItemRepository feedItemRepository;

    private final PlatformTransactionManager transactionManager;
    private final OpenaiService openaiService;
    private final UserService userService;
    private final EntityManager entityManager;
    private final FeedRepository feedRepository;
    private final FeedErrorRepository feedErrorRepository;

    @Autowired
    public FeedItemService(FeedItemRepository feedItemRepository, PlatformTransactionManager transactionManager, OpenaiService openaiService, FeedService feedService, UserService userService, EntityManager entityManager, FeedRepository feedRepository, FeedErrorRepository feedErrorRepository) {
        this.feedItemRepository = feedItemRepository;
        this.transactionManager = transactionManager;
        this.openaiService = openaiService;
        this.feedService = feedService;
        this.userService = userService;
        this.entityManager = entityManager;
        this.feedRepository = feedRepository;
        this.feedErrorRepository = feedErrorRepository;
    }

    public void refreshFeed(Feed feed) {
        exec.submit(() -> refreshFeedWorker(feed));
    }

    private void refreshFeedWorker(Feed feed) {
        try {
            logger.info("Refreshing feed {}", feed.getId());
            RssReader reader;
            reader = new RssReader();
            List<Item> items = reader
                    .addFeedFilter(new InvalidXmlCharacterFilter())
                    .addItemExtension("media:thumbnail", "url", (item, s) -> {
                        System.out.println(s);
                        Enclosure enclosure = new Enclosure();
                        enclosure.setType("image");
                        enclosure.setUrl(s);
                        item.addEnclosure(enclosure);
                    })
                    .read(feed.getUrl())
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
                                // TODO: remove when stuff is stable
                                if (imageUrl != null && !imageUrl.isEmpty() && !imageUrl.equals(existingFeed.getImageUrl())) {
                                    existingFeed.setImageUrl(imageUrl);
                                    feedItemRepository.save(existingFeed);
                                }
                                logger.info("Feed {} already processed", item.getGuid().get());
                                return;
                            }

                            var analysis = openaiService.processFeedItem(item, feed.getUser());
                            if (analysis.isPresent()) {

                                FeedItem newItem = new FeedItem();
                                newItem.setId(UUID.randomUUID().toString());
                                newItem.setFeed(feed);
                                newItem.setUrl(item.getLink().orElse(null));
                                newItem.setGuid(item.getGuid().get());
                                newItem.setDescription(item.getDescription().orElse(null));
                                newItem.setTitle(item.getTitle().orElse(null));
                                newItem.setContent(item.getContent().orElse(null));
                                newItem.setImportance(analysis.get().importance());
                                newItem.setReasoning(analysis.get().reasoning());
                                newItem.setImageUrl(imageUrl);
                                newItem.setTimeCreated(item.getPubDateZonedDateTime()
                                        .map(zonedDateTime -> zonedDateTime.toInstant().toEpochMilli())
                                        .orElse(System.currentTimeMillis()));

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
        }
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

    @Transactional(readOnly = true)
    public Page<FeedItem> getItems(Long from, Long to, int page, int pageSize) throws SQLException {

        List<Feed> feeds = feedService.getFeeds();
        var user = userService.getCurrentUser();

        return feedItemRepository.findallByTimeAndFeeds(user.getMinimumImportance(), from, to, feeds, PageRequest.of(page, pageSize, Sort.by(List.of(new Sort.Order(Sort.Direction.DESC, "importance"), new Sort.Order(Sort.Direction.DESC, "timeCreated")))));
    }

    @Transactional(readOnly = true)
    public List<FeedItem> search(String query, int page, int pageSize) {
        var feeds = feedRepository.getFeedsByUser(userService.getCurrentUser());
        return entityManager.createNativeQuery(String.format("select * from feed_items where search_terms @@ websearch_to_tsquery(:textQuery) and feed_id in :feeds limit :pageSize offset :page"), FeedItem.class)
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
        var feeds = feedRepository.getFeedsByUser(userService.getCurrentUser());
        var items = feedItemRepository.findByIdInAndFeedIn(ids, feeds);

        items.forEach(feedItem -> feedItem.setRead(true));

        feedItemRepository.saveAll(items);

        return true;
    }
}
