package com.github.lamarios.newsku.controllers;

import com.github.lamarios.newsku.persistence.entities.FeedItem;
import com.github.lamarios.newsku.persistence.entities.LayoutBlock;
import com.github.lamarios.newsku.persistence.entities.MagazineTab;
import com.github.lamarios.newsku.services.FeedItemService;
import com.github.lamarios.newsku.services.LayoutService;
import com.github.lamarios.newsku.services.MagazineTabService;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/public/magazine")
@Tag(name = "Public Magazine")
public class PublicMagazineController {

    private final MagazineTabService magazineTabService;
    private final LayoutService layoutService;
    private final FeedItemService feedItemService;

    @Autowired
    public PublicMagazineController(MagazineTabService magazineTabService, LayoutService layoutService, FeedItemService feedItemService) {
        this.magazineTabService = magazineTabService;
        this.layoutService = layoutService;
        this.feedItemService = feedItemService;
    }

    @GetMapping("/{tabId}/layout")
    public List<LayoutBlock> getPublicTabLayout(@PathVariable String tabId) {
        MagazineTab tab = magazineTabService.getPublicTab(tabId);
        return layoutService.getTabLayout(tab);
    }

    @GetMapping("/{tabId}/items")
    public Page<FeedItem> getPublicTabItems(
            @PathVariable String tabId,
            @RequestParam("from") long from,
            @RequestParam("to") long to,
            @RequestParam(value = "page", defaultValue = "0") int page,
            @RequestParam(value = "pageSize", defaultValue = "100") int pageSize
    ) {
        MagazineTab tab = magazineTabService.getPublicTab(tabId);
        return feedItemService.getPublicItems(tab, from, to, page, pageSize);
    }
}
