package com.github.lamarios.newsku.services;

import com.github.lamarios.newsku.persistence.entities.Feed;
import com.github.lamarios.newsku.persistence.repositories.FeedRepository;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

@Service
public class ScheduleService {

    private static final Logger logger = LogManager.getLogger();

    private final FeedRepository feedRepository;
    private final FeedItemService feedItemService;
    private final FreshRssSyncService freshRssSyncService;

    @Autowired
    public ScheduleService(FeedRepository feedRepository, FeedItemService feedItemService, FreshRssSyncService freshRssSyncService) {
        this.feedRepository = feedRepository;
        this.feedItemService = feedItemService;
        this.freshRssSyncService = freshRssSyncService;
    }

    @Scheduled(fixedRate = 1000 * 60 * 60)
    public void refreshFeeds() {
        // Legacy direct-RSS refresh (runs for feeds not managed via FreshRSS)
        var feeds = feedRepository.findAll();
        for (Feed feed : feeds) {
            if (feed.getFreshRssFeedId() == null || feed.getFreshRssFeedId().isBlank()) {
                feedItemService.refreshFeed(feed);
            }
        }

        // FreshRSS-backed refresh for all configured users
        try {
            freshRssSyncService.syncAll();
        } catch (Exception e) {
            logger.error("FreshRSS syncAll failed: {}", e.getMessage(), e);
        }
    }
}
