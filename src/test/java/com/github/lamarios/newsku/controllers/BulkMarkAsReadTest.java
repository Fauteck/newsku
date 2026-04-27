package com.github.lamarios.newsku.controllers;

import com.github.lamarios.newsku.TestConfig;
import com.github.lamarios.newsku.TestContainerTest;
import com.github.lamarios.newsku.errors.NewskuException;
import com.github.lamarios.newsku.persistence.entities.FeedItem;
import com.github.lamarios.newsku.services.FeedItemService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.context.annotation.Import;

import java.sql.SQLException;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

@Import(TestConfig.class)
public class BulkMarkAsReadTest extends TestContainerTest {

    @Autowired
    private FeedItemController feedItemController;

    @Autowired
    private FeedItemService feedItemService;

    @Autowired
    private FeedController feedController;

    @LocalServerPort
    private int port;

    @Test
    public void markAllRead_withoutFeedId_marksEverythingOlderThanCutoff() throws SQLException, NewskuException {
        var feed = feedController.addFeed("http://localhost:" + port + "/test/rss/one-month-feed", true);
        feedItemService.refreshFeedWorker(feed);

        var before = feedItemController.getItems(0L, System.currentTimeMillis(), 0, 500, null, null, null, null);
        long unreadBefore = before.getContent().stream().filter(i -> !i.isRead()).count();
        assertTrue(unreadBefore > 0, "feed has unread items to flip");

        int flipped = feedItemController.markAllRead(System.currentTimeMillis(), null);
        assertEquals(unreadBefore, flipped);

        var after = feedItemController.getItems(0L, System.currentTimeMillis(), 0, 500, null, null, null, null);
        assertTrue(after.getContent().stream().allMatch(FeedItem::isRead),
                "every item is read after the bulk call");
    }

    @Test
    public void markAllRead_unknownFeedId_isNoOp() throws SQLException, NewskuException {
        var feed = feedController.addFeed("http://localhost:" + port + "/test/rss/one-month-feed", true);
        feedItemService.refreshFeedWorker(feed);

        int flipped = feedItemController.markAllRead(System.currentTimeMillis(), "this-feed-id-does-not-exist");
        assertEquals(0, flipped, "no items should be flipped for an unknown feedId");

        var items = feedItemController.getItems(0L, System.currentTimeMillis(), 0, 500, null, null, null, null);
        assertTrue(items.getContent().stream().anyMatch(i -> !i.isRead()),
                "items remain unread");
    }
}
