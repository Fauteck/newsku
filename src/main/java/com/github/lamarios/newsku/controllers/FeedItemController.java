package com.github.lamarios.newsku.controllers;

import com.github.lamarios.newsku.models.PageResponse;
import com.github.lamarios.newsku.persistence.entities.FeedItem;
import com.github.lamarios.newsku.services.FeedItemService;
import com.github.lamarios.newsku.services.ImageCacheService;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.InvalidParameterException;
import java.sql.SQLException;
import java.util.List;

@RestController
@RequestMapping("/api/feeds/items")
@Tag(name = "Feeds")
@SecurityRequirement(name = "bearerAuth")
@Validated
public class FeedItemController {
    private final FeedItemService feedItemService;
    private final ImageCacheService imageCacheService;
    private final Logger log = LogManager.getLogger();

    @Autowired
    public FeedItemController(FeedItemService feedItemService, ImageCacheService imageCacheService) {
        this.feedItemService = feedItemService;
        this.imageCacheService = imageCacheService;
    }

    @GetMapping
    public PageResponse<FeedItem> getItems(
            @RequestParam("from") Long from,
            @RequestParam("to") Long to,
            @RequestParam(value = "page", defaultValue = "0") @Min(0) int page,
            @RequestParam(value = "pageSize", defaultValue = "100") @Min(1) @Max(2000) int pageSize,
            @RequestParam(value = "minimumImportance", required = false) Integer minimumImportance,
            @RequestParam(value = "sort", required = false) String sort,
            @RequestParam(value = "feedId", required = false) String feedId,
            @RequestParam(value = "categoryId", required = false) String categoryId
    ) throws SQLException {
        if (from == null || to == null) {
            throw new InvalidParameterException("from and to query parameters are required");
        }
        return PageResponse.of(feedItemService.getItems(from, to, page, pageSize, minimumImportance, sort, feedId, categoryId));
    }

    @PostMapping("/read")
    public boolean readArticles(@RequestBody List<String> ids) {
        log.info("Changing read status of {} items", ids.size());
        return feedItemService.readItems(ids);
    }

    /**
     * Bulk mark-as-read for the "everything older than X is read" pattern.
     *
     * @param before  cutoff timestamp in epoch millis; items with
     *                {@code timeCreated <= before} are flipped to read
     * @param feedId  optional — when set, restricts the operation to that
     *                single feed; when omitted, every feed of the current
     *                user is included
     * @return number of items that were unread before the call and are read now
     */
    @PostMapping("/mark-all-read")
    public int markAllRead(
            @RequestParam("before") @Min(0) long before,
            @RequestParam(value = "feedId", required = false) String feedId
    ) {
        int n = feedItemService.markAllRead(before, feedId);
        log.info("Bulk mark-as-read flipped {} items (feedId={}, before={})", n, feedId, before);
        return n;
    }

    @GetMapping("/saved")
    public List<FeedItem> getSavedArticles() {
        return feedItemService.getSavedItems();
    }

    /**
     * Paginated variant of {@link #getSavedArticles()}. Default sort is
     * "most recently saved first" — what users expect when their bookmark
     * list grows past a few dozen items. The sort field is allow-listed so
     * Spring Data's permissive Pageable binder cannot expose internal
     * columns ("password", "id", etc.) as a sort key.
     */
    private static final java.util.Set<String> ALLOWED_SAVED_SORT_FIELDS =
            java.util.Set.of("savedAt", "timeCreated", "importance");

    @GetMapping("/saved/page")
    public PageResponse<FeedItem> getSavedArticlesPaged(
            @RequestParam(value = "page", defaultValue = "0") @Min(0) int page,
            @RequestParam(value = "pageSize", defaultValue = "50") @Min(1) @Max(500) int pageSize,
            @RequestParam(value = "sort", defaultValue = "savedAt") String sort,
            @RequestParam(value = "direction", defaultValue = "desc") String direction
    ) {
        String sortField = ALLOWED_SAVED_SORT_FIELDS.contains(sort) ? sort : "savedAt";
        Sort.Direction dir = "asc".equalsIgnoreCase(direction) ? Sort.Direction.ASC : Sort.Direction.DESC;
        var pageable = PageRequest.of(page, pageSize, Sort.by(dir, sortField));
        return PageResponse.of(feedItemService.getSavedItems(pageable));
    }

    @PutMapping("/{id}/saved")
    public FeedItem toggleSaved(@PathVariable String id) {
        log.info("Toggling saved status of item {}", id);
        return feedItemService.toggleSaved(id);
    }

    @PutMapping("/{id}/click")
    public void clickItem(@PathVariable String id) {
        feedItemService.itemClicked(id);
    }

    @GetMapping("/{id}/image")
    public ResponseEntity<StreamingResponseBody> getArticleImage(@PathVariable String id) throws IOException, SQLException {

        var item = feedItemService.getItem(id);

        if (item == null || item.getImageUrl() == null || item.getImageUrl().isBlank()) {
            return ResponseEntity.status(404).build();
        }

        var filePath = imageCacheService.getCachedImage(id, item.getImageUrl());

        return serveFile(filePath);
    }

    public static ResponseEntity<StreamingResponseBody> serveFile(Path filePath) throws IOException {
        String contentType = Files.probeContentType(filePath);
        if (contentType == null) {
            contentType = "application/octet-stream";
        }

        long fileSize = Files.size(filePath);

        StreamingResponseBody responseBody = outputStream -> {
            try (InputStream inputStream = new FileInputStream(filePath.toFile())) {
                byte[] buffer = new byte[8192]; // 8KB buffer
                int bytesRead;
                while ((bytesRead = inputStream.read(buffer)) != -1) {
                    outputStream.write(buffer, 0, bytesRead);
                }
                outputStream.flush();
            }
        };

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_TYPE, contentType)
                .header(HttpHeaders.CONTENT_LENGTH, String.valueOf(fileSize))
                .body(responseBody);
    }
}
