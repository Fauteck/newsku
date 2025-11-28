package com.github.lamarios.newsku.controllers;

import com.github.lamarios.newsku.models.AppConfig;
import com.github.lamarios.newsku.services.OidcService;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/config")
@Tag(name = "misc")
public class ConfigController {
    private final OidcService oidcService;
    private final boolean allowSignUp;
    private final String announcement;

    @Autowired
    public ConfigController(OidcService oidcService, @Value("${ALLOW_SIGNUP:0}") boolean allowSignUp, @Value("${ANNOUNCEMENT:}") String announcement) {
        this.oidcService = oidcService;
        this.allowSignUp = allowSignUp;
        this.announcement = announcement;
    }

    @GetMapping
    public AppConfig getConfig() {
        AppConfig config = new AppConfig();
        config.setAnnouncement(announcement);
        config.setAllowSignup(allowSignUp);

        if (oidcService.getOidcDiscoveryUrl() != null) {
            config.setOidcConfig(oidcService.getOidcConfig());
        }

        return config;
    }
}
