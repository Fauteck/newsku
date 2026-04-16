package com.github.lamarios.newsku.services;

import com.github.lamarios.newsku.models.greader.GReaderStreamContents;
import com.github.lamarios.newsku.models.greader.GReaderSubscription;
import com.github.lamarios.newsku.models.greader.GReaderSubscriptionList;
import com.github.lamarios.newsku.models.greader.GReaderTag;
import com.github.lamarios.newsku.models.greader.GReaderTagList;
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
 * Low-level Google Reader API client.
 *
 * Compatible with any GReader-API implementation (FreshRSS, Miniflux, Miniflux, etc.).
 *
 * Authentication:
 *   POST /accounts/ClientLogin  →  Auth token (cached 23 h, shared across all users)
 *   GET  /reader/api/0/token    →  Modification token (fetched per write operation)
 *
 * Credentials are read from environment variables:
 *   GREADER_URL           – base URL of the GReader instance  (required to enable integration)
 *   GREADER_USERNAME      – GReader username / e-mail
 *   GREADER_API_PASSWORD  – GReader API password
 *
 * All methods are no-ops / return empty when GReader is not fully configured.
 */
@Service
public class GReaderApiService {

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

    /** Batch size for edit-tag POST requests */
    private static final int EDIT_TAG_BATCH = 50;

    private final String baseUrl;
    private final String username;
    private final String password;
    private final RestClient restClient;

    /** Single shared token (credentials are global, not per-user). */
    private final AtomicReference<CachedToken> cachedToken = new AtomicReference<>();

    public GReaderApiService(
            @Value("${GREADER_URL:}") String baseUrl,
            @Value("${GREADER_USERNAME:}") String username,
            @Value("${GREADER_API_PASSWORD:}") String password) {
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

    /** Returns true when GREADER_URL is set. */
    public boolean isConfigured() {
        return !baseUrl.isBlank();
    }

    /** Returns true when URL, username and password are all set via environment variables. */
    public boolean isCredentialsConfigured() {
        return isConfigured()
                && username != null && !username.isBlank()
                && password != null && !password.isBlank();
    }

    // -----------------------------------------------------------------------
    // Public API
    // -----------------------------------------------------------------------

    /** Returns all subscriptions (feeds), or an empty list if not configured. */
    public List<GReaderSubscription> getSubscriptions(User user) {
        if (!isCredentialsConfigured()) return Collections.emptyList();
        try {
            var result = restClient.get()
                    .uri("/api/greader.php/reader/api/0/subscription/list?output=json")
                    .header("Authorization", authHeader())
                    .retrieve()
                    .body(GReaderSubscriptionList.class);
            return result != null && result.getSubscriptions() != null
                    ? result.getSubscriptions()
                    : Collections.emptyList();
        } catch (RestClientException e) {
            logger.error("Failed to fetch GReader subscriptions: {}", e.getMessage());
            return Collections.emptyList();
        }
    }

    /** Returns all user-defined labels/categories, or an empty list if not configured. */
    public List<GReaderTag> getTags(User user) {
        if (!isCredentialsConfigured()) return Collections.emptyList();
        try {
            var result = restClient.get()
                    .uri("/api/greader.php/reader/api/0/tag/list?output=json")
                    .header("Authorization", authHeader())
                    .retrieve()
                    .body(GReaderTagList.class);
            if (result == null || result.getTags() == null) return Collections.emptyList();
            return result.getTags().stream().filter(GReaderTag::isUserLabel).toList();
        } catch (RestClientException e) {
            logger.error("Failed to fetch GReader tags: {}", e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Fetches one page of unread stream items.
     *
     * @param user         kept for API compatibility
     * @param continuation pagination cursor from a previous response, or null for the first page
     */
    public GReaderStreamContents getUnreadItems(User user, String continuation) {
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
                    .body(GReaderStreamContents.class);
            return result != null ? result : emptyStream();
        } catch (RestClientException e) {
            logger.error("Failed to fetch GReader unread stream: {}", e.getMessage());
            return emptyStream();
        }
    }

    /**
     * Fetches one page of starred items.
     *
     * @param continuation pagination cursor from a previous response, or null for the first page
     */
    public GReaderStreamContents getStarredItems(User user, String continuation) {
        if (!isCredentialsConfigured()) return emptyStream();
        try {
            String uri = "/api/greader.php/reader/api/0/stream/contents/user/-/state/com.google/starred"
                    + "?output=json"
                    + "&n=" + PAGE_SIZE
                    + (continuation != null ? "&c=" + continuation : "");

            var result = restClient.get()
                    .uri(uri)
                    .header("Authorization", authHeader())
                    .retrieve()
                    .body(GReaderStreamContents.class);
            return result != null ? result : emptyStream();
        } catch (RestClientException e) {
            logger.error("Failed to fetch GReader starred items: {}", e.getMessage());
            return emptyStream();
        }
    }

    /**
     * Marks the given GReader item IDs as read.
     *
     * @param gReaderItemIds list of full tag URIs, e.g. "tag:google.com,2005:reader/item/..."
     */
    public void markAsRead(User user, List<String> gReaderItemIds) {
        editTag(gReaderItemIds, "user/-/state/com.google/read", true);
    }

    /**
     * Sets or clears the starred state for the given GReader item IDs.
     *
     * @param gReaderItemIds list of full tag URIs
     * @param starred        true to star, false to unstar
     */
    public void markAsStarred(User user, List<String> gReaderItemIds, boolean starred) {
        editTag(gReaderItemIds, "user/-/state/com.google/starred", starred);
    }

    // -----------------------------------------------------------------------
    // Internal helpers
    // -----------------------------------------------------------------------

    private void editTag(List<String> itemIds, String tag, boolean add) {
        if (!isCredentialsConfigured() || itemIds.isEmpty()) return;
        try {
            String modToken = fetchModificationToken();
            for (int i = 0; i < itemIds.size(); i += EDIT_TAG_BATCH) {
                List<String> batch = itemIds.subList(i, Math.min(i + EDIT_TAG_BATCH, itemIds.size()));
                MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
                form.add("T", modToken);
                form.add(add ? "a" : "r", tag);
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
            logger.error("Failed to edit tag '{}' (add={}) in GReader: {}", tag, add, e.getMessage());
        }
    }

    private String authHeader() {
        return "GoogleLogin auth=" + getAuthToken();
    }

    private String getAuthToken() {
        CachedToken cached = cachedToken.get();
        if (cached != null && !cached.isExpired()) {
            return cached.token();
        }

        logger.info("Authenticating against GReader as '{}'", username);
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
            throw new IllegalStateException("GReader auth failed for user '" + username + "': no Auth token in response");
        }

        CachedToken newToken = new CachedToken(token, System.currentTimeMillis() + TOKEN_TTL_MS);
        cachedToken.set(newToken);
        return token;
    }

    private String fetchModificationToken() {
        return restClient.get()
                .uri("/api/greader.php/reader/api/0/token")
                .header("Authorization", authHeader())
                .retrieve()
                .body(String.class);
    }

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

    private static GReaderStreamContents emptyStream() {
        GReaderStreamContents empty = new GReaderStreamContents();
        empty.setItems(new ArrayList<>());
        return empty;
    }

    public void invalidateToken() {
        cachedToken.set(null);
    }
}
