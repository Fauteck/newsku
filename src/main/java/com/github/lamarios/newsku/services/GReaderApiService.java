package com.github.lamarios.newsku.services;

import com.github.lamarios.newsku.errors.NewskuException;
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
import java.util.concurrent.ConcurrentHashMap;

/**
 * Low-level Google Reader API client.
 *
 * Compatible with any GReader-API implementation (FreshRSS, Miniflux, etc.).
 *
 * Authentication:
 *   POST /accounts/ClientLogin  →  Auth token (cached 23 h, per user)
 *   GET  /reader/api/0/token    →  Modification token (fetched per write operation)
 *
 * Credentials are resolved per call:
 *   1. User-level fields on the {@link User} entity (primary)
 *   2. Environment-variable fallbacks GREADER_URL / GREADER_USERNAME / GREADER_API_PASSWORD
 *
 * All methods are no-ops / return empty when credentials aren't configured for the user.
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

    /** Resolved credentials for a single user (user values overriding env defaults). */
    private record Credentials(String baseUrl, String username, String password) {
        boolean isComplete() {
            return baseUrl != null && !baseUrl.isBlank()
                    && username != null && !username.isBlank()
                    && password != null && !password.isBlank();
        }
    }

    /** Max items to fetch per GReader page */
    private static final int PAGE_SIZE = 100;

    /** Auth token TTL: 23 hours */
    private static final long TOKEN_TTL_MS = 23L * 60 * 60 * 1000;

    /** Batch size for edit-tag POST requests */
    private static final int EDIT_TAG_BATCH = 50;

    private final String defaultBaseUrl;
    private final String defaultUsername;
    private final String defaultPassword;

    /** Per-user auth-token cache, keyed by user id. */
    private final ConcurrentHashMap<String, CachedToken> tokenCache = new ConcurrentHashMap<>();

    public GReaderApiService(
            @Value("${GREADER_URL:}") String baseUrl,
            @Value("${GREADER_USERNAME:}") String username,
            @Value("${GREADER_API_PASSWORD:}") String password) {
        this.defaultBaseUrl = stripTrailingSlash(baseUrl);
        this.defaultUsername = username;
        this.defaultPassword = password;
    }

    // -----------------------------------------------------------------------
    // Configuration checks
    // -----------------------------------------------------------------------

    /** Returns true when URL, username and password are all configured for the given user. */
    public boolean isCredentialsConfigured(User user) {
        return resolve(user).isComplete();
    }

    // -----------------------------------------------------------------------
    // Public API
    // -----------------------------------------------------------------------

    /** Returns all subscriptions (feeds), or an empty list if not configured. */
    public List<GReaderSubscription> getSubscriptions(User user) {
        Credentials creds = resolve(user);
        if (!creds.isComplete()) return Collections.emptyList();
        try {
            var result = clientFor(creds).get()
                    .uri("/api/greader.php/reader/api/0/subscription/list?output=json")
                    .header("Authorization", authHeader(user, creds))
                    .retrieve()
                    .body(GReaderSubscriptionList.class);
            return result != null && result.getSubscriptions() != null
                    ? result.getSubscriptions()
                    : Collections.emptyList();
        } catch (RestClientException e) {
            logger.error("Failed to fetch GReader subscriptions for user {}: {}", user.getUsername(), e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Like {@link #getSubscriptions(User)}, but propagates transport and auth errors
     * instead of swallowing them. Intended for on-demand UI-triggered syncs so the
     * user can see why a sync failed.
     */
    public List<GReaderSubscription> getSubscriptionsOrThrow(User user) throws NewskuException {
        Credentials creds = resolve(user);
        if (!creds.isComplete()) {
            throw new NewskuException("GReader credentials not configured");
        }
        try {
            var result = clientFor(creds).get()
                    .uri("/api/greader.php/reader/api/0/subscription/list?output=json")
                    .header("Authorization", authHeader(user, creds))
                    .retrieve()
                    .body(GReaderSubscriptionList.class);
            return result != null && result.getSubscriptions() != null
                    ? result.getSubscriptions()
                    : Collections.emptyList();
        } catch (RestClientException | IllegalStateException e) {
            throw new NewskuException("GReader subscription fetch failed: " + e.getMessage());
        }
    }

    /** Returns all user-defined labels/categories, or an empty list if not configured. */
    public List<GReaderTag> getTags(User user) {
        Credentials creds = resolve(user);
        if (!creds.isComplete()) return Collections.emptyList();
        try {
            var result = clientFor(creds).get()
                    .uri("/api/greader.php/reader/api/0/tag/list?output=json")
                    .header("Authorization", authHeader(user, creds))
                    .retrieve()
                    .body(GReaderTagList.class);
            if (result == null || result.getTags() == null) return Collections.emptyList();
            return result.getTags().stream().filter(GReaderTag::isUserLabel).toList();
        } catch (RestClientException e) {
            logger.error("Failed to fetch GReader tags for user {}: {}", user.getUsername(), e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Like {@link #getTags(User)}, but propagates transport and auth errors
     * instead of swallowing them. Intended for on-demand UI-triggered syncs.
     */
    public List<GReaderTag> getTagsOrThrow(User user) throws NewskuException {
        Credentials creds = resolve(user);
        if (!creds.isComplete()) {
            throw new NewskuException("GReader credentials not configured");
        }
        try {
            var result = clientFor(creds).get()
                    .uri("/api/greader.php/reader/api/0/tag/list?output=json")
                    .header("Authorization", authHeader(user, creds))
                    .retrieve()
                    .body(GReaderTagList.class);
            if (result == null || result.getTags() == null) return Collections.emptyList();
            return result.getTags().stream().filter(GReaderTag::isUserLabel).toList();
        } catch (RestClientException | IllegalStateException e) {
            throw new NewskuException("GReader tag fetch failed: " + e.getMessage());
        }
    }

    /**
     * Fetches one page of unread stream items.
     *
     * @param continuation pagination cursor from a previous response, or null for the first page
     */
    public GReaderStreamContents getUnreadItems(User user, String continuation) {
        Credentials creds = resolve(user);
        if (!creds.isComplete()) return emptyStream();
        try {
            String uri = "/api/greader.php/reader/api/0/stream/contents/user/-/state/com.google/reading-list"
                    + "?output=json"
                    + "&n=" + PAGE_SIZE
                    + "&xt=user/-/state/com.google/read"
                    + (continuation != null ? "&c=" + continuation : "");

            var result = clientFor(creds).get()
                    .uri(uri)
                    .header("Authorization", authHeader(user, creds))
                    .retrieve()
                    .body(GReaderStreamContents.class);
            return result != null ? result : emptyStream();
        } catch (RestClientException e) {
            logger.error("Failed to fetch GReader unread stream for user {}: {}", user.getUsername(), e.getMessage());
            return emptyStream();
        }
    }

    /**
     * Fetches one page of starred items.
     *
     * @param continuation pagination cursor from a previous response, or null for the first page
     */
    public GReaderStreamContents getStarredItems(User user, String continuation) {
        Credentials creds = resolve(user);
        if (!creds.isComplete()) return emptyStream();
        try {
            String uri = "/api/greader.php/reader/api/0/stream/contents/user/-/state/com.google/starred"
                    + "?output=json"
                    + "&n=" + PAGE_SIZE
                    + (continuation != null ? "&c=" + continuation : "");

            var result = clientFor(creds).get()
                    .uri(uri)
                    .header("Authorization", authHeader(user, creds))
                    .retrieve()
                    .body(GReaderStreamContents.class);
            return result != null ? result : emptyStream();
        } catch (RestClientException e) {
            logger.error("Failed to fetch GReader starred items for user {}: {}", user.getUsername(), e.getMessage());
            return emptyStream();
        }
    }

    /**
     * Marks the given GReader item IDs as read.
     *
     * @param gReaderItemIds list of full tag URIs, e.g. "tag:google.com,2005:reader/item/..."
     */
    public void markAsRead(User user, List<String> gReaderItemIds) {
        editTag(user, gReaderItemIds, "user/-/state/com.google/read", true);
    }

    /**
     * Sets or clears the starred state for the given GReader item IDs.
     *
     * @param gReaderItemIds list of full tag URIs
     * @param starred        true to star, false to unstar
     */
    public void markAsStarred(User user, List<String> gReaderItemIds, boolean starred) {
        editTag(user, gReaderItemIds, "user/-/state/com.google/starred", starred);
    }

    // -----------------------------------------------------------------------
    // Internal helpers
    // -----------------------------------------------------------------------

    private void editTag(User user, List<String> itemIds, String tag, boolean add) {
        if (itemIds.isEmpty()) return;
        Credentials creds = resolve(user);
        if (!creds.isComplete()) return;
        try {
            RestClient client = clientFor(creds);
            String modToken = fetchModificationToken(client, user, creds);
            for (int i = 0; i < itemIds.size(); i += EDIT_TAG_BATCH) {
                List<String> batch = itemIds.subList(i, Math.min(i + EDIT_TAG_BATCH, itemIds.size()));
                MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
                form.add("T", modToken);
                form.add(add ? "a" : "r", tag);
                batch.forEach(id -> form.add("i", id));

                client.post()
                        .uri("/api/greader.php/reader/api/0/edit-tag")
                        .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                        .header("Authorization", authHeader(user, creds))
                        .body(form)
                        .retrieve()
                        .toBodilessEntity();
            }
        } catch (RestClientException e) {
            logger.error("Failed to edit tag '{}' (add={}) in GReader for user {}: {}",
                    tag, add, user.getUsername(), e.getMessage());
        }
    }

    /** Resolves credentials: user-level values take precedence over env-var defaults. */
    private Credentials resolve(User user) {
        String url = user != null && user.getGReaderUrl() != null && !user.getGReaderUrl().isBlank()
                ? stripTrailingSlash(user.getGReaderUrl())
                : defaultBaseUrl;
        String username = user != null && user.getGReaderUsername() != null && !user.getGReaderUsername().isBlank()
                ? user.getGReaderUsername()
                : defaultUsername;
        String password = user != null && user.getGReaderApiPassword() != null && !user.getGReaderApiPassword().isBlank()
                ? user.getGReaderApiPassword()
                : defaultPassword;
        return new Credentials(url, username, password);
    }

    private RestClient clientFor(Credentials creds) {
        return RestClient.builder().baseUrl(creds.baseUrl()).build();
    }

    private String authHeader(User user, Credentials creds) {
        return "GoogleLogin auth=" + getAuthToken(user, creds);
    }

    private String getAuthToken(User user, Credentials creds) {
        String cacheKey = user.getId();
        CachedToken cached = tokenCache.get(cacheKey);
        if (cached != null && !cached.isExpired()) {
            return cached.token();
        }

        logger.info("Authenticating against GReader as '{}' (user {})", creds.username(), user.getUsername());
        MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("Email", creds.username());
        form.add("Passwd", creds.password());

        String body = clientFor(creds).post()
                .uri("/api/greader.php/accounts/ClientLogin")
                .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                .body(form)
                .retrieve()
                .body(String.class);

        String token = parseKeyValue(body, "Auth");
        if (token == null || token.isBlank()) {
            throw new IllegalStateException("GReader auth failed for user '" + user.getUsername() + "': no Auth token in response");
        }

        CachedToken newToken = new CachedToken(token, System.currentTimeMillis() + TOKEN_TTL_MS);
        tokenCache.put(cacheKey, newToken);
        return token;
    }

    private String fetchModificationToken(RestClient client, User user, Credentials creds) {
        return client.get()
                .uri("/api/greader.php/reader/api/0/token")
                .header("Authorization", authHeader(user, creds))
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

    private static String stripTrailingSlash(String url) {
        if (url == null) return "";
        return url.endsWith("/") ? url.substring(0, url.length() - 1) : url;
    }

    public void invalidateToken(User user) {
        if (user != null && user.getId() != null) {
            tokenCache.remove(user.getId());
        }
    }
}
