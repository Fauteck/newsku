package com.github.lamarios.newsku.persistence.entities;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.github.lamarios.newsku.models.EmailDigestFrequency;
import com.github.lamarios.newsku.models.ReadItemHandling;
import com.github.lamarios.newsku.persistence.converters.StringCryptoConverter;
import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.List;

@Entity
@Table(name = "users")
public class User {

    @Id
    private String id;
    private String username;
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private String password;
    private String email;
    @Column(name = "feed_item_preference")
    private String feedItemPreference;
    @Column(name = "oidc_sub")
    private String oidcSub;
    @Column(name = "minimum_importance")
    private int minimumImportance;

    @Column(name = "read_item_handling")
    @Enumerated(EnumType.STRING)
    private ReadItemHandling readItemHandling;

    @Column(name = "first_time_setup_done")
    private boolean firstTimeSetupDone;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "email_digest")
    @Enumerated(EnumType.STRING)
    private List<EmailDigestFrequency> emailDigest;

    @JsonProperty("gReaderUsername")
    @Column(name = "freshrss_username")
    private String gReaderUsername;

    @JsonProperty(value = "gReaderApiPassword", access = JsonProperty.Access.WRITE_ONLY)
    @Column(name = "freshrss_api_password")
    @Convert(converter = StringCryptoConverter.class)
    private String gReaderApiPassword;

    @JsonProperty("gReaderUrl")
    @Column(name = "freshrss_url")
    private String gReaderUrl;

    @Column(name = "ai_prompt_id")
    private String aiPromptId;

    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    @Column(name = "openai_api_key")
    @Convert(converter = StringCryptoConverter.class)
    private String openAiApiKey;

    @Column(name = "openai_model")
    private String openAiModel;

    @Column(name = "openai_url")
    private String openAiUrl;

    @Column(name = "enable_text_shortening")
    private Boolean enableTextShortening;

    @Column(name = "openai_monthly_token_limit_relevance")
    private Integer openAiMonthlyTokenLimitRelevance;

    @Column(name = "openai_monthly_token_limit_shortening")
    private Integer openAiMonthlyTokenLimitShortening;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getFeedItemPreference() {
        return feedItemPreference;
    }

    public void setFeedItemPreference(String feedItemPreference) {
        this.feedItemPreference = feedItemPreference;
    }

    public String getOidcSub() {
        return oidcSub;
    }

    public void setOidcSub(String oidcSub) {
        this.oidcSub = oidcSub;
    }

    public int getMinimumImportance() {
        return minimumImportance;
    }

    public void setMinimumImportance(int minimumImportance) {
        this.minimumImportance = minimumImportance;
    }


    public ReadItemHandling getReadItemHandling() {
        return readItemHandling;
    }

    public void setReadItemHandling(ReadItemHandling readItemHandling) {
        this.readItemHandling = readItemHandling;
    }

    public boolean isFirstTimeSetupDone() {
        return firstTimeSetupDone;
    }

    public void setFirstTimeSetupDone(boolean firstTimeSetupDone) {
        this.firstTimeSetupDone = firstTimeSetupDone;
    }

    public List<EmailDigestFrequency> getEmailDigest() {
        return emailDigest;
    }

    public void setEmailDigest(List<EmailDigestFrequency> emailDigest) {
        this.emailDigest = emailDigest;
    }

    public String getGReaderUsername() {
        return gReaderUsername;
    }

    public void setGReaderUsername(String gReaderUsername) {
        this.gReaderUsername = gReaderUsername;
    }

    public String getGReaderApiPassword() {
        return gReaderApiPassword;
    }

    public void setGReaderApiPassword(String gReaderApiPassword) {
        this.gReaderApiPassword = gReaderApiPassword;
    }

    public String getGReaderUrl() {
        return gReaderUrl;
    }

    public void setGReaderUrl(String gReaderUrl) {
        this.gReaderUrl = gReaderUrl;
    }

    public String getAiPromptId() {
        return aiPromptId;
    }

    public void setAiPromptId(String aiPromptId) {
        this.aiPromptId = aiPromptId;
    }

    public String getOpenAiApiKey() {
        return openAiApiKey;
    }

    public void setOpenAiApiKey(String openAiApiKey) {
        this.openAiApiKey = openAiApiKey;
    }

    public String getOpenAiModel() {
        return openAiModel;
    }

    public void setOpenAiModel(String openAiModel) {
        this.openAiModel = openAiModel;
    }

    public String getOpenAiUrl() {
        return openAiUrl;
    }

    public void setOpenAiUrl(String openAiUrl) {
        this.openAiUrl = openAiUrl;
    }

    public Boolean getEnableTextShortening() {
        return enableTextShortening;
    }

    public void setEnableTextShortening(Boolean enableTextShortening) {
        this.enableTextShortening = enableTextShortening;
    }

    public Integer getOpenAiMonthlyTokenLimitRelevance() {
        return openAiMonthlyTokenLimitRelevance;
    }

    public void setOpenAiMonthlyTokenLimitRelevance(Integer openAiMonthlyTokenLimitRelevance) {
        this.openAiMonthlyTokenLimitRelevance = openAiMonthlyTokenLimitRelevance;
    }

    public Integer getOpenAiMonthlyTokenLimitShortening() {
        return openAiMonthlyTokenLimitShortening;
    }

    public void setOpenAiMonthlyTokenLimitShortening(Integer openAiMonthlyTokenLimitShortening) {
        this.openAiMonthlyTokenLimitShortening = openAiMonthlyTokenLimitShortening;
    }
}
