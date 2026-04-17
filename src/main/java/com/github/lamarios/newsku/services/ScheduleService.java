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
    private final GReaderSyncService gReaderSyncService;

    @Autowired
    public ScheduleService(FeedRepository feedRepository, FeedItemService feedItemService, GReaderSyncService gReaderSyncService) {
        this.feedRepository = feedRepository;
        this.feedItemService = feedItemService;
        this.gReaderSyncService = gReaderSyncService;
    }

    @Scheduled(cron = "${FEED_SYNC_CRON:0 15,35,55 * * * *}")
    public void refreshFeeds() {
        // Legacy direct-RSS refresh (runs for feeds not managed via GReader)
        var feeds = feedRepository.findAll();
        for (Feed feed : feeds) {
            if (feed.getGReaderFeedId() == null || feed.getGReaderFeedId().isBlank()) {
                feedItemService.refreshFeed(feed);
            }
        }

        // GReader-backed refresh for all configured users
        try {
            gReaderSyncService.syncAll();
        } catch (Exception e) {
            logger.error("GReader syncAll failed: {}", e.getMessage(), e);
        }
    }
}
