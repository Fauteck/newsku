package com.github.lamarios.newsku.models;

public class AppConfig {
    private boolean allowSignup;
    private OIDCConfig oidcConfig;
    private String announcement;

    public String getAnnouncement() {
        return announcement;
    }

    public void setAnnouncement(String announcement) {
        this.announcement = announcement;
    }

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
