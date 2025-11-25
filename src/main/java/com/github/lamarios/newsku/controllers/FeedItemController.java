package com.github.lamarios.newsku.controllers;

import com.github.lamarios.newsku.persistence.entities.FeedItem;
import com.github.lamarios.newsku.services.FeedItemService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.bind.DefaultValue;
import org.springframework.data.domain.Page;
import org.springframework.web.bind.annotation.*;

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
}
