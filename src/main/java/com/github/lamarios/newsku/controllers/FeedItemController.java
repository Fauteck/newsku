package com.github.lamarios.newsku.controllers;

import com.github.lamarios.newsku.persistence.entities.FeedItem;
import com.github.lamarios.newsku.services.FeedItemService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.bind.DefaultValue;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.net.URLConnection;
import java.security.InvalidParameterException;
import java.sql.SQLException;
import java.util.List;

@RestController
@RequestMapping("/api/feeds/items")
@Tag(name = "Feeds")
@SecurityRequirement(name = "bearerAuth")
public class FeedItemController {
    private final FeedItemService feedItemService;

    @Autowired
    public FeedItemController(FeedItemService feedItemService) {
        this.feedItemService = feedItemService;
    }

    @GetMapping
    public Page<FeedItem> getItems(@RequestParam("from") Long from, @RequestParam("to") Long to, @DefaultValue("0") @RequestParam("page") int page, @DefaultValue("100") @RequestParam("pageSize") int pageSize) throws SQLException {
        if (from == null || to == null) {
            throw new InvalidParameterException("from and to query parameters are required");
        }
        return feedItemService.getItems(from, to, page, pageSize);
    }

    @GetMapping("/{id}/image")
    public ResponseEntity<byte[]> getArticleImage(@PathVariable String id) throws IOException, SQLException {

        var item = feedItemService.getItem(id);

        if(item  == null || item.getImageUrl() == null || item.getImageUrl().isBlank()){
            return ResponseEntity.status(404).build();
        }

        // Fetch from remote URL
        try (InputStream in = new URL(item.getImageUrl()).openStream()) {
            byte[] imageBytes = in.readAllBytes();

            // Guess content type
            String contentType = URLConnection.guessContentTypeFromStream(new ByteArrayInputStream(imageBytes));
            if (contentType == null) {
                contentType = "application/octet-stream";
            }

            return ResponseEntity
                    .ok()
                    .header(HttpHeaders.CONTENT_TYPE, contentType)
                    .body(imageBytes);
        }
    }
}
