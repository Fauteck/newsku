package com.github.lamarios.newsku.services;

import com.github.lamarios.newsku.errors.NewskuUserException;
import com.github.lamarios.newsku.persistence.entities.LayoutBlock;
import com.github.lamarios.newsku.persistence.entities.MagazineTab;
import com.github.lamarios.newsku.persistence.repositories.MagazineTabRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class MagazineTabService {

    private final MagazineTabRepository magazineTabRepository;
    private final UserService userService;
    private final LayoutService layoutService;

    @Autowired
    public MagazineTabService(MagazineTabRepository magazineTabRepository, UserService userService, LayoutService layoutService) {
        this.magazineTabRepository = magazineTabRepository;
        this.userService = userService;
        this.layoutService = layoutService;
    }

    @Transactional(readOnly = true)
    public List<MagazineTab> getTabs() {
        return magazineTabRepository.findByUserOrderByDisplayOrder(userService.getCurrentUser());
    }

    @Transactional
    public MagazineTab createTab(MagazineTab tab) {
        tab.setId(UUID.randomUUID().toString());
        tab.setUser(userService.getCurrentUser());
        return magazineTabRepository.save(tab);
    }

    @Transactional
    public MagazineTab updateTab(String id, MagazineTab updated) {
        var user = userService.getCurrentUser();
        var existing = magazineTabRepository.findById(id)
                .filter(t -> t.getUser().getId().equals(user.getId()))
                .orElseThrow(() -> new NewskuUserException("Tab not found"));

        existing.setName(updated.getName());
        existing.setDisplayOrder(updated.getDisplayOrder());
        existing.setPublic(updated.isPublic());
        existing.setAiPreference(updated.getAiPreference());
        existing.setMinimumImportance(updated.getMinimumImportance());
        return magazineTabRepository.save(existing);
    }

    @Transactional
    public void deleteTab(String id) {
        var user = userService.getCurrentUser();
        var tab = magazineTabRepository.findById(id)
                .filter(t -> t.getUser().getId().equals(user.getId()))
                .orElseThrow(() -> new NewskuUserException("Tab not found"));
        magazineTabRepository.delete(tab);
    }

    @Transactional(readOnly = true)
    public List<LayoutBlock> getTabLayout(String id) {
        var user = userService.getCurrentUser();
        var tab = magazineTabRepository.findById(id)
                .filter(t -> t.getUser().getId().equals(user.getId()))
                .orElseThrow(() -> new NewskuUserException("Tab not found"));
        return layoutService.getTabLayout(tab);
    }

    @Transactional
    public List<LayoutBlock> setTabLayout(String id, List<LayoutBlock> blocks) {
        var user = userService.getCurrentUser();
        var tab = magazineTabRepository.findById(id)
                .filter(t -> t.getUser().getId().equals(user.getId()))
                .orElseThrow(() -> new NewskuUserException("Tab not found"));
        return layoutService.setTabLayout(tab, blocks);
    }

    @Transactional(readOnly = true)
    public MagazineTab getPublicTab(String id) {
        return magazineTabRepository.findByIdAndIsPublicTrue(id)
                .orElseThrow(() -> new NewskuUserException("Tab not found or not public"));
    }
}
