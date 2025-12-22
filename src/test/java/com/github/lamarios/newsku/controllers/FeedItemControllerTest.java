package com.github.lamarios.newsku.controllers;

import com.github.lamarios.newsku.TestConfig;
import com.github.lamarios.newsku.TestContainerTest;
import com.github.lamarios.newsku.persistence.entities.FeedItem;
import com.github.lamarios.newsku.services.FeedItemService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;

import java.io.IOException;
import java.sql.SQLException;

import static org.junit.jupiter.api.Assertions.assertTrue;

@Import(TestConfig.class)
public class FeedItemControllerTest extends TestContainerTest {
    @Autowired
    private FeedItemController feedItemController;

    @Autowired
    private FeedItemService feedItemService;

    @Autowired
    private FeedController feedController;


    @Test
    public void testFeedItems() throws SQLException, IOException {
        var feed = feedController.addFeed("https://feeds.arstechnica.com/arstechnica/index");

        feedItemService.refreshFeedWorker(feed);

        var items = feedItemController.getItems(0L, System.currentTimeMillis(), 0, 9999999);

        assertTrue(items.hasContent());


        assertTrue(items.getContent().stream().noneMatch(FeedItem::isRead));

        feedItemController.readArticles(items.getContent().stream().map(FeedItem::getId).toList());


        items = feedItemController.getItems(0L, System.currentTimeMillis(), 0, 9999999);
        assertTrue(items.getContent().stream().allMatch(FeedItem::isRead));
    }
}
