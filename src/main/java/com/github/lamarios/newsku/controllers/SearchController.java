package com.github.lamarios.newsku.controllers;

import com.github.lamarios.newsku.persistence.entities.FeedItem;
import com.github.lamarios.newsku.services.FeedItemService;
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
    public List<FeedItem> search(
            @RequestParam("query") String query,
            @RequestParam(value = "page", defaultValue = "0") @Min(0) int page,
            @RequestParam(value = "pageSize", defaultValue = "100") @Min(1) @Max(500) int size) {
        return feedItemService.search(query, page, size);
    }
}
