package com.github.lamarios.newsku.controllers;

import com.github.lamarios.newsku.persistence.entities.Feed;
import com.github.lamarios.newsku.services.FeedItemService;
import com.github.lamarios.newsku.services.FeedService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@RestController
@RequestMapping("/api/feeds")
@Tag(name = "Feeds")
@SecurityRequirement(name = "bearerAuth")
public class FeedController {
    private final FeedService feedService;
    private final FeedItemService feedItemService;

    @Autowired
    public FeedController(FeedService feedService, FeedItemService feedItemService) {
        this.feedService = feedService;
        this.feedItemService = feedItemService;
    }

    @GetMapping
    public List<Feed> getFeeds() throws SQLException {
        return feedService.getFeeds();
    }

    @PostMapping
    public Feed updateFeed(Feed feed) throws SQLException {
        return feedService.updateFeed(feed);
    }

    @PutMapping
    public Feed addFeed(@RequestBody String url) throws SQLException, IOException {
        var feed = feedService.addFeed(url);
        feedItemService.refreshFeed(feed);
        return feed;
    }

    @DeleteMapping("{id}")
    public boolean deleteFeed(@PathVariable String id) throws SQLException {
return feedService.deleteFeed(id);
    }
}
