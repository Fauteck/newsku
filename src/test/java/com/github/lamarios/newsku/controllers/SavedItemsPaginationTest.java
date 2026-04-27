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
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

@Import(TestConfig.class)
public class SavedItemsPaginationTest extends TestContainerTest {

    @Autowired
    private FeedItemController feedItemController;

    @Autowired
    private FeedItemService feedItemService;

    @Autowired
    private FeedController feedController;

    @LocalServerPort
    private int port;

    @Test
    public void savedPaged_defaultSort_returnsMostRecentFirst() throws SQLException, NewskuException, InterruptedException {
        var feed = feedController.addFeed("http://localhost:" + port + "/test/rss/one-month-feed", true);
        feedItemService.refreshFeedWorker(feed);

        var items = feedItemController.getItems(0L, System.currentTimeMillis(), 0, 500, null, null, null, null);
        assertTrue(items.hasContent(), "feed has items to save");

        // Save the first three items in known order. Sleep 5ms between toggles
        // so System.currentTimeMillis() (used by setSaved) produces a strict
        // ordering even on fast clocks.
        List<FeedItem> toSave = items.getContent().subList(0, Math.min(3, items.getContent().size()));
        for (FeedItem item : toSave) {
            feedItemController.toggleSaved(item.getId());
            Thread.sleep(5);
        }

        var page = feedItemController.getSavedArticlesPaged(0, 50, "savedAt", "desc");
        assertEquals(toSave.size(), page.totalElements());

        // Most recently saved item should appear first.
        assertEquals(toSave.get(toSave.size() - 1).getId(), page.content().get(0).getId());
    }

    @Test
    public void savedPaged_unknownSortField_fallsBackToSavedAt() throws SQLException, NewskuException {
        var feed = feedController.addFeed("http://localhost:0/test/rss/one-month-feed", true);
        feedItemService.refreshFeedWorker(feed);
        var items = feedItemController.getItems(0L, System.currentTimeMillis(), 0, 500, null, null, null, null);
        if (!items.getContent().isEmpty()) {
            feedItemController.toggleSaved(items.getContent().get(0).getId());
        }

        // "password" is not in the allow-list and must be silently ignored.
        var page = feedItemController.getSavedArticlesPaged(0, 50, "password", "desc");
        assertFalse(page.content().isEmpty());
    }
}
