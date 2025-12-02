package com.github.lamarios.newsku.controllers;

import be.ceau.opml.OpmlParseException;
import be.ceau.opml.OpmlWriteException;
import com.github.lamarios.newsku.persistence.entities.Feed;
import com.github.lamarios.newsku.services.FeedItemService;
import com.github.lamarios.newsku.services.FeedService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.apache.commons.io.IOUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.net.URL;

import org.springframework.security.access.AccessDeniedException;

import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.SQLException;
import java.util.List;

import static com.github.lamarios.newsku.controllers.FeedItemController.serveFile;

@RestController
@RequestMapping("/api/feeds")
@Tag(name = "Feeds")
@SecurityRequirement(name = "bearerAuth")
public class FeedController {
    private final FeedService feedService;
    private final FeedItemService feedItemService;
    private final Path tempDir;
    private final Logger log = LogManager.getLogger();
    private final boolean demoMode;

    @Autowired
    public FeedController(FeedService feedService, FeedItemService feedItemService, @Value("${DEMO_MODE:0}") boolean demoMode) throws IOException {
        this.feedService = feedService;
        this.feedItemService = feedItemService;
        this.demoMode = demoMode;
        this.tempDir = Files.createTempDirectory("newsku-feed-images");
    }

    @GetMapping
    public List<Feed> getFeeds() throws SQLException {
        return feedService.getFeeds();
    }

    @PostMapping
    public Feed updateFeed(Feed feed) throws SQLException, AccessDeniedException {
        if (demoMode) {
            throw new AccessDeniedException("App in demoMode");
        }
        return feedService.updateFeed(feed);
    }

    @PutMapping
    public Feed addFeed(@RequestBody String url) throws SQLException, IOException {
        if (demoMode) {
            throw new AccessDeniedException("App in demoMode");
        }
        var feed = feedService.addFeed(url);
        feedItemService.refreshFeed(feed);
        return feed;
    }

    @DeleteMapping("{id}")
    public boolean deleteFeed(@PathVariable String id) throws SQLException, AccessDeniedException {
        if (demoMode) {
            throw new AccessDeniedException("App in demoMode");
        }
        return feedService.deleteFeed(id);
    }

    @PostMapping(value = "/import", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public List<Feed> importFeed(@RequestParam("file") MultipartFile file) throws OpmlParseException, IOException, SQLException {
        if (demoMode) {
            throw new AccessDeniedException("App in demoMode");
        }
        var newFeeds = feedService.importFeed(file);

        newFeeds.forEach(feedItemService::refreshFeed);
        return newFeeds;
    }


    @GetMapping("/export")
    public ResponseEntity<byte[]> exportFeeds() throws IOException, OpmlWriteException {
        if (demoMode) {
            throw new AccessDeniedException("App in demoMode");
        }
        Path p = Files.createTempFile("ompl-export", ".opml");
        String opml = feedService.exportFeed();

        try (PrintWriter printer = new PrintWriter(p.toFile().getAbsolutePath())) {
            IOUtils.write(opml, printer);

        }
        return serveFile(p);

    }


    @GetMapping("/{id}/image")
    public ResponseEntity<byte[]> getFeedImage(@PathVariable String id) throws IOException, SQLException {

        Feed item = feedService.getFeed(id);

        if (item == null || item.getImage() == null || item.getImage().isBlank()) {
            return ResponseEntity.status(404).build();
        }

        var filePath = tempDir.resolve(id);

        if (!filePath.toFile().exists()) {
            log.info("File doesn't exist in cache, caching it...");
            try (InputStream in = new URL(item.getImage()).openStream()) {
                byte[] imageBytes = in.readAllBytes();

                Files.write(filePath, imageBytes);
                // Guess content type
            }
        } else {
            log.info("Serving from cache");
        }


        // Fetch from remote URL
        return serveFile(filePath);
    }

}
