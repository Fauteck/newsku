package com.github.lamarios.newsku.services;

import com.github.lamarios.newsku.models.freshrss.FreshRssStreamContents;
import com.github.lamarios.newsku.models.freshrss.FreshRssSubscription;
import com.github.lamarios.newsku.models.freshrss.FreshRssSubscriptionList;
import com.github.lamarios.newsku.models.freshrss.FreshRssTag;
import com.github.lamarios.newsku.models.freshrss.FreshRssTagList;
import com.github.lamarios.newsku.persistence.entities.User;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.atomic.AtomicReference;

/**
 * Low-level Google Reader API client for FreshRSS.
 *
 * Authentication:
 *   POST /accounts/ClientLogin  →  Auth token (cached 23 h, shared across all users)
 *   GET  /reader/api/0/token    →  Modification token (fetched per write operation)
 *
 * Credentials are read from environment variables:
 *   FRESHRSS_URL       – base URL of the FreshRSS instance  (required to enable integration)
 *   FRESHRSS_USERNAME  – FreshRSS username / e-mail
 *   FRESHRSS_API_PASSWORD – FreshRSS API password (Google Reader password, not the login password)
 *
 * All methods are no-ops / return empty when FreshRSS is not fully configured.
 */
@Service
public class FreshRssApiService {

    private static final Logger logger = LogManager.getLogger();

    /** Cached auth token */
    private record CachedToken(String token, long expiresAt) {
        boolean isExpired() {
            return System.currentTimeMillis() > expiresAt;
        }
    }

    /** Max items to fetch per GReader page */
    private static final int PAGE_SIZE = 100;

    /** Auth token TTL: 23 hours */
    private static final long TOKEN_TTL_MS = 23L * 60 * 60 * 1000;

    /** Batch size for mark-as-read POST requests */
    private static final int MARK_READ_BATCH = 50;

    private final String baseUrl;
    private final String username;
    private final String password;
    private final RestClient restClient;

    /** Single shared token (credentials are global, not per-user). */
    private final AtomicReference<CachedToken> cachedToken = new AtomicReference<>();

    public FreshRssApiService(
            @Value("${FRESHRSS_URL:}") String baseUrl,
            @Value("${FRESHRSS_USERNAME:}") String username,
            @Value("${FRESHRSS_API_PASSWORD:}") String password) {
        this.baseUrl = baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl;
        this.username = username;
        this.password = password;
        this.restClient = baseUrl.isBlank() ? null : RestClient.builder()
                .baseUrl(this.baseUrl)
                .build();
    }

    // -----------------------------------------------------------------------
    // Configuration checks
    // -----------------------------------------------------------------------

    /** Returns true when FRESHRSS_URL is set. */
    public boolean isConfigured() {
        return !baseUrl.isBlank();
    }

    /**
     * Returns true when URL, username and password are all set via environment variables.
     * The {@code user} parameter is kept for API compatibility but is no longer used for auth.
     */
    public boolean isCredentialsConfigured() {
        return isConfigured()
                && username != null && !username.isBlank()
                && password != null && !password.isBlank();
    }

    /**
     * @deprecated Use {@link #isCredentialsConfigured()} instead.
     *             Credentials are now global (env vars), not per-user.
     */
    @Deprecated
    public boolean isUserConfigured(User user) {
        return isCredentialsConfigured();
    }

    // -----------------------------------------------------------------------
    // Public API  (User parameter kept for API compatibility only)
    // -----------------------------------------------------------------------

    /**
     * Returns all subscriptions (feeds), or an empty list if not configured.
     */
    public List<FreshRssSubscription> getSubscriptions(User user) {
        if (!isCredentialsConfigured()) return Collections.emptyList();
        try {
            var result = restClient.get()
                    .uri("/api/greader.php/reader/api/0/subscription/list?output=json")
                    .header("Authorization", authHeader())
                    .retrieve()
                    .body(FreshRssSubscriptionList.class);
            return result != null && result.getSubscriptions() != null
                    ? result.getSubscriptions()
                    : Collections.emptyList();
        } catch (RestClientException e) {
            logger.error("Failed to fetch FreshRSS subscriptions: {}", e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Returns all user-defined labels/categories, or an empty list if not configured.
     */
    public List<FreshRssTag> getTags(User user) {
        if (!isCredentialsConfigured()) return Collections.emptyList();
        try {
            var result = restClient.get()
                    .uri("/api/greader.php/reader/api/0/tag/list?output=json")
                    .header("Authorization", authHeader())
                    .retrieve()
                    .body(FreshRssTagList.class);
            if (result == null || result.getTags() == null) return Collections.emptyList();
            return result.getTags().stream().filter(FreshRssTag::isUserLabel).toList();
        } catch (RestClientException e) {
            logger.error("Failed to fetch FreshRSS tags: {}", e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Fetches one page of unread stream items.
     *
     * @param user         kept for API compatibility; not used for auth
     * @param continuation pagination cursor from a previous response, or null for the first page
     */
    public FreshRssStreamContents getUnreadItems(User user, String continuation) {
        if (!isCredentialsConfigured()) return emptyStream();
        try {
            String uri = "/api/greader.php/reader/api/0/stream/contents/user/-/state/com.google/reading-list"
                    + "?output=json"
                    + "&n=" + PAGE_SIZE
                    + "&xt=user/-/state/com.google/read"
                    + (continuation != null ? "&c=" + continuation : "");

            var result = restClient.get()
                    .uri(uri)
                    .header("Authorization", authHeader())
                    .retrieve()
                    .body(FreshRssStreamContents.class);
            return result != null ? result : emptyStream();
        } catch (RestClientException e) {
            logger.error("Failed to fetch FreshRSS stream: {}", e.getMessage());
            return emptyStream();
        }
    }

    /**
     * Marks the given FreshRSS item IDs as read.
     *
     * @param user            kept for API compatibility; not used for auth
     * @param freshRssItemIds list of full tag URIs, e.g. "tag:google.com,2005:reader/item/..."
     */
    public void markAsRead(User user, List<String> freshRssItemIds) {
        if (!isCredentialsConfigured() || freshRssItemIds.isEmpty()) return;
        try {
            String modToken = fetchModificationToken();
            for (int i = 0; i < freshRssItemIds.size(); i += MARK_READ_BATCH) {
                List<String> batch = freshRssItemIds.subList(i, Math.min(i + MARK_READ_BATCH, freshRssItemIds.size()));
                MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
                form.add("T", modToken);
                form.add("a", "user/-/state/com.google/read");
                batch.forEach(id -> form.add("i", id));

                restClient.post()
                        .uri("/api/greader.php/reader/api/0/edit-tag")
                        .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                        .header("Authorization", authHeader())
                        .body(form)
                        .retrieve()
                        .toBodilessEntity();
            }
        } catch (RestClientException e) {
            logger.error("Failed to mark items as read in FreshRSS: {}", e.getMessage());
        }
    }

    // -----------------------------------------------------------------------
    // Internal helpers
    // -----------------------------------------------------------------------

    private String authHeader() {
        return "GoogleLogin auth=" + getAuthToken();
    }

    /**
     * Returns a valid auth token, re-authenticating if the cached token is expired.
     */
    private String getAuthToken() {
        CachedToken cached = cachedToken.get();
        if (cached != null && !cached.isExpired()) {
            return cached.token();
        }

        logger.info("Authenticating against FreshRSS as '{}'", username);
        MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("Email", username);
        form.add("Passwd", password);

        String body = restClient.post()
                .uri("/api/greader.php/accounts/ClientLogin")
                .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                .body(form)
                .retrieve()
                .body(String.class);

        String token = parseKeyValue(body, "Auth");
        if (token == null || token.isBlank()) {
            throw new IllegalStateException("FreshRSS auth failed for user '" + username + "': no Auth token in response");
        }

        CachedToken newToken = new CachedToken(token, System.currentTimeMillis() + TOKEN_TTL_MS);
        cachedToken.set(newToken);
        return token;
    }

    /**
     * Fetches a short-lived modification token required for POST write operations.
     */
    private String fetchModificationToken() {
        return restClient.get()
                .uri("/api/greader.php/reader/api/0/token")
                .header("Authorization", authHeader())
                .retrieve()
                .body(String.class);
    }

    /** Parses a plain-text "key=value\n..." response as returned by ClientLogin. */
    private static String parseKeyValue(String body, String key) {
        if (body == null) return null;
        for (String line : body.split("\n")) {
            line = line.trim();
            if (line.startsWith(key + "=")) {
                return line.substring(key.length() + 1);
            }
        }
        return null;
    }

    private static FreshRssStreamContents emptyStream() {
        FreshRssStreamContents empty = new FreshRssStreamContents();
        empty.setItems(new ArrayList<>());
        return empty;
    }

    /**
     * Invalidates the cached auth token (e.g. after a credential change via env var reload).
     */
    public void invalidateToken() {
        cachedToken.set(null);
    }

    /** @deprecated Use {@link #invalidateToken()} instead. */
    @Deprecated
    public void invalidateToken(String userId) {
        invalidateToken();
    }
}
