package com.github.lamarios.newsku.models;

import com.fasterxml.jackson.annotation.JsonProperty;

public class AppConfig {
    private boolean allowSignup;
    private OIDCConfig oidcConfig;
    private String announcement;
    private boolean demoMode;
    private String backendVersion;
    private boolean canResetPassword;

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

    public boolean isDemoMode() {
        return demoMode;
    }

    public void setDemoMode(boolean demoMode) {
        this.demoMode = demoMode;
    }

    public String getBackendVersion() {
        return backendVersion;
    }

    public void setBackendVersion(String backendVersion) {
        this.backendVersion = backendVersion;
    }

    public boolean isCanResetPassword() {
        return canResetPassword;
    }

    public void setCanResetPassword(boolean canResetPassword) {
        this.canResetPassword = canResetPassword;
    }

    @JsonProperty("gReaderUrl")
    private String gReaderUrl;

    public String getGReaderUrl() {
        return gReaderUrl;
    }

    public void setGReaderUrl(String gReaderUrl) {
        this.gReaderUrl = gReaderUrl;
    }
}
