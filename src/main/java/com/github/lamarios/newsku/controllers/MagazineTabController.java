package com.github.lamarios.newsku.controllers;

import com.github.lamarios.newsku.persistence.entities.LayoutBlock;
import com.github.lamarios.newsku.persistence.entities.MagazineTab;
import com.github.lamarios.newsku.services.MagazineTabService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/magazine/tabs")
@Tag(name = "Magazine")
@SecurityRequirement(name = "bearerAuth")
public class MagazineTabController {

    private final MagazineTabService magazineTabService;

    @Autowired
    public MagazineTabController(MagazineTabService magazineTabService) {
        this.magazineTabService = magazineTabService;
    }

    @GetMapping
    public List<MagazineTab> getTabs() {
        return magazineTabService.getTabs();
    }

    @PostMapping
    public MagazineTab createTab(@RequestBody MagazineTab tab) {
        return magazineTabService.createTab(tab);
    }

    @PutMapping("/{id}")
    public MagazineTab updateTab(@PathVariable String id, @RequestBody MagazineTab tab) {
        return magazineTabService.updateTab(id, tab);
    }

    @DeleteMapping("/{id}")
    public void deleteTab(@PathVariable String id) {
        magazineTabService.deleteTab(id);
    }

    @GetMapping("/{id}/layout")
    public List<LayoutBlock> getTabLayout(@PathVariable String id) {
        return magazineTabService.getTabLayout(id);
    }

    @PutMapping("/{id}/layout")
    public List<LayoutBlock> setTabLayout(@PathVariable String id, @RequestBody List<LayoutBlock> blocks) {
        return magazineTabService.setTabLayout(id, blocks);
    }
}
