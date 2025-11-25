package com.github.lamarios.newsku.services;

import com.apptasticsoftware.rssreader.Item;
import com.apptasticsoftware.rssreader.RssReader;
import com.apptasticsoftware.rssreader.filter.InvalidXmlCharacterFilter;
import com.github.lamarios.newsku.persistence.entities.Feed;
import com.github.lamarios.newsku.persistence.entities.FeedItem;
import com.github.lamarios.newsku.persistence.repositories.FeedItemRepository;
import com.github.lamarios.newsku.utils.TransactionHelper;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Transactional;

import java.sql.SQLException;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@Service
public class FeedItemService {
    private final static Logger logger = LogManager.getLogger();
    private final FeedService feedService;
    private ExecutorService exec = Executors.newSingleThreadExecutor();

    private final FeedItemRepository feedItemRepository;

    private final PlatformTransactionManager transactionManager;
    private final OpenaiService openaiService;

    @Autowired
    public FeedItemService(FeedItemRepository feedItemRepository, PlatformTransactionManager transactionManager, OpenaiService openaiService, FeedService feedService) {
        this.feedItemRepository = feedItemRepository;
        this.transactionManager = transactionManager;
        this.openaiService = openaiService;
        this.feedService = feedService;
    }

    public void refreshFeed(Feed feed) {
        exec.submit(() -> refreshFeedWorker(feed));
    }

    private void refreshFeedWorker(Feed feed) {
        try {
            logger.info("Refreshing feed {}", feed.getId());
            RssReader reader;
            reader = new RssReader();
            List<Item> items = reader.addFeedFilter(new InvalidXmlCharacterFilter())
                    .read(feed.getUrl())
                    .sorted()
                    .filter(item -> item.getGuid().isPresent())
                    .toList();

            for (Item item : items) {
                TransactionHelper.doInNewTransaction(transactionManager, false, () -> {

                    var existingFeed = feedItemRepository.getFirstByGuid(item.getGuid().get());

                    if (existingFeed != null) {
                        logger.info("Feed {} already processed", item.getGuid().get());
                        return;
                    }

                    var analysis = openaiService.processFeedItem(item);
                    if (analysis.isPresent()) {
                        FeedItem newItem = new FeedItem();
                        newItem.setId(UUID.randomUUID().toString());
                        newItem.setFeed(feed);
                        newItem.setGuid(item.getGuid().get());
                        newItem.setDescription(item.getDescription().orElse(null));
                        newItem.setTitle(item.getTitle().orElse(null));
                        newItem.setContent(item.getContent().orElse(null));
                        newItem.setImportance(analysis.get().importance());
                        newItem.setReasoning(analysis.get().reasoning());
                        newItem.setImageUrl(analysis.get().imageUrl());
                        newItem.setTimeCreated(item.getPubDateZonedDateTime()
                                .map(zonedDateTime -> zonedDateTime.toInstant().toEpochMilli())
                                .orElse(System.currentTimeMillis()));

                        feedItemRepository.save(newItem);
                    }

                });
            }
        } catch (Exception e) {
            logger.error("Couldn't parse feed: {}", feed.getUrl(), e);
        }
    }

    @Transactional(readOnly = true)
    public Page<FeedItem> getItems(Long from, Long to, int page, int pageSize) throws SQLException {

        List<Feed> feeds = feedService.getFeeds();

        return feedItemRepository.findallByTimeAndFeeds(from, to, feeds, PageRequest.of(page, pageSize, Sort.by(List.of(new Sort.Order(Sort.Direction.DESC, "importance"), new Sort.Order(Sort.Direction.DESC, "timeCreated")))));
    }
}
