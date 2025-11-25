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
@Tag(name="misc")
public class ConfigController {
    private final OidcService oidcService;
    private final boolean allowSignUp;
    @Autowired
    public ConfigController(OidcService oidcService, @Value("${ALLOW_SIGNUP:0}")boolean allowSignUp) {
        this.oidcService = oidcService;
        this.allowSignUp = allowSignUp;
    }

    @GetMapping
    public AppConfig getConfig() {
        AppConfig config = new AppConfig();
        config.setAllowSignup(allowSignUp);

        if (oidcService.getOidcDiscoveryUrl() != null) {
            config.setOidcConfig(oidcService.getOidcConfig());
        }

        return config;
    }
}
