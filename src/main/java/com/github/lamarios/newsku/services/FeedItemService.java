package com.github.lamarios.newsku.services;

import com.apptasticsoftware.rssreader.Enclosure;
import com.apptasticsoftware.rssreader.Item;
import com.apptasticsoftware.rssreader.RssReader;
import com.apptasticsoftware.rssreader.filter.InvalidXmlCharacterFilter;
import com.github.lamarios.newsku.persistence.entities.Feed;
import com.github.lamarios.newsku.persistence.entities.FeedItem;
import com.github.lamarios.newsku.persistence.repositories.FeedItemRepository;
import com.github.lamarios.newsku.utils.TransactionHelper;
import com.openai.models.beta.threads.messages.ImageUrl;
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
                    if (item.getLink().isEmpty()) {
                        return;
                    }

                    try {
                        var existingFeed = feedItemRepository.getFirstByGuid(item.getGuid().get());

                        Optional<String> image = item.getEnclosure()
                                .filter(e -> e.getType().contains("image"))
                                .map(Enclosure::getUrl);

                        String imageUrl = image.orElse(getImageUrl(item));

                        if (existingFeed != null) {
                            logger.info("Feed {} already processed", item.getGuid().get());
                            return;
                        }

                        var analysis = openaiService.processFeedItem(item);
                        if (analysis.isPresent()) {

                            FeedItem newItem = new FeedItem();
                            newItem.setId(UUID.randomUUID().toString());
                            newItem.setFeed(feed);
                            newItem.setGuid(item.getLink().get());
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
                    }
                });
            }
        } catch (Exception e) {
            logger.error("Couldn't parse feed: {}", feed.getUrl(), e);
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

        return feedItemRepository.findallByTimeAndFeeds(from, to, feeds, PageRequest.of(page, pageSize, Sort.by(List.of(new Sort.Order(Sort.Direction.DESC, "importance"), new Sort.Order(Sort.Direction.DESC, "timeCreated")))));
    }

    @Transactional(readOnly = true)
    public FeedItem getItem(String id) throws SQLException {

        List<Feed> feeds = feedService.getFeeds();

        return feedItemRepository.findFirstByIdAndFeedIn(id, feeds).stream().findFirst().orElse(null);
    }
}
