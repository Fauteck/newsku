package com.github.lamarios.newsku.controllers;

import com.github.lamarios.newsku.persistence.entities.FeedItem;
import com.github.lamarios.newsku.services.FeedItemService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/search")
@Tag(name = "Search")
@SecurityRequirement(name = "bearerAuth")
@Validated
public class SearchController {

    private final FeedItemService feedItemService;

    public SearchController(FeedItemService feedItemService) {
        this.feedItemService = feedItemService;
    }


    @GetMapping
    @Operation(
            summary = "Full-text search articles",
            description = "Searches the current user's feed items by title and content. " +
                    "Results are ordered by relevance, paginated, and limited to a maximum " +
                    "of 500 items per page to keep response sizes bounded."
    )
    @ApiResponse(responseCode = "200", description = "List of matching feed items for the requested page")
    @ApiResponse(responseCode = "400", description = "Invalid pagination parameters (e.g. pageSize > 500)")
    @ApiResponse(responseCode = "401", description = "Missing or invalid bearer token")
    public List<FeedItem> search(
            @Parameter(description = "Free-text search query. Matched against title and content.", required = true)
            @RequestParam("query") String query,
            @Parameter(description = "Zero-based page index.", example = "0")
            @RequestParam(value = "page", defaultValue = "0") @Min(0) int page,
            @Parameter(description = "Page size (1–500). Defaults to 100.", example = "100")
            @RequestParam(value = "pageSize", defaultValue = "100") @Min(1) @Max(500) int size) {
        return feedItemService.search(query, page, size);
    }
}
