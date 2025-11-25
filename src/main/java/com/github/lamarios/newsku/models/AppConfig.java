package com.github.lamarios.newsku.models;

public class AppConfig {
    private boolean allowSignup;
    private OIDCConfig oidcConfig;

    public OIDCConfig getOidcConfig() {
        return oidcConfig;
    }

    public void setOidcConfig(OIDCConfig oidcConfig) {
        this.oidcConfig = oidcConfig;
    }

    public boolean isAllowSignup() {
        return allowSignup;
    }

    public void setAllowSignup(boolean allowSignup) {
        this.allowSignup = allowSignup;
    }
}
