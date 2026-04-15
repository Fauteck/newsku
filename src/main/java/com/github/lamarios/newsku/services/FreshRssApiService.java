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
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Low-level Google Reader API client for FreshRSS.
 *
 * Authentication:
 *   POST /accounts/ClientLogin  →  Auth token (cached 23 h per user)
 *   GET  /reader/api/0/token    →  Modification token (fetched per write operation)
 *
 * All methods are no-ops / return empty when FreshRSS is not configured
 * (FRESHRSS_URL env var not set) or the user has no FreshRSS credentials.
 */
@Service
public class FreshRssApiService {

    private static final Logger logger = LogManager.getLogger();

    /** Cached auth token entry */
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
    private final RestClient restClient;
    private final Map<String, CachedToken> tokenCache = new ConcurrentHashMap<>();

    public FreshRssApiService(@Value("${FRESHRSS_URL:}") String baseUrl) {
        this.baseUrl = baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl;
        this.restClient = baseUrl.isBlank() ? null : RestClient.builder()
                .baseUrl(this.baseUrl)
                .build();
    }

    // -----------------------------------------------------------------------
    // Public API
    // -----------------------------------------------------------------------

    public boolean isConfigured() {
        return !baseUrl.isBlank();
    }

    public boolean isUserConfigured(User user) {
        return isConfigured()
                && user.getFreshRssUsername() != null
                && !user.getFreshRssUsername().isBlank()
                && user.getFreshRssApiPassword() != null
                && !user.getFreshRssApiPassword().isBlank();
    }

    /**
     * Returns all subscriptions (feeds) for the user, or an empty list if not configured.
     */
    public List<FreshRssSubscription> getSubscriptions(User user) {
        if (!isUserConfigured(user)) return Collections.emptyList();
        try {
            var result = restClient.get()
                    .uri("/api/greader.php/reader/api/0/subscription/list?output=json")
                    .header("Authorization", authHeader(user))
                    .retrieve()
                    .body(FreshRssSubscriptionList.class);
            return result != null && result.getSubscriptions() != null
                    ? result.getSubscriptions()
                    : Collections.emptyList();
        } catch (RestClientException e) {
            logger.error("Failed to fetch FreshRSS subscriptions for user {}: {}", user.getUsername(), e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Returns all user-defined labels/categories, or an empty list if not configured.
     */
    public List<FreshRssTag> getTags(User user) {
        if (!isUserConfigured(user)) return Collections.emptyList();
        try {
            var result = restClient.get()
                    .uri("/api/greader.php/reader/api/0/tag/list?output=json")
                    .header("Authorization", authHeader(user))
                    .retrieve()
                    .body(FreshRssTagList.class);
            if (result == null || result.getTags() == null) return Collections.emptyList();
            return result.getTags().stream().filter(FreshRssTag::isUserLabel).toList();
        } catch (RestClientException e) {
            logger.error("Failed to fetch FreshRSS tags for user {}: {}", user.getUsername(), e.getMessage());
            return Collections.emptyList();
        }
    }

    /**
     * Fetches one page of unread stream items.
     *
     * @param user         the user whose reading list to fetch
     * @param continuation pagination cursor from a previous response, or null for the first page
     * @return stream contents including items and optional next continuation token
     */
    public FreshRssStreamContents getUnreadItems(User user, String continuation) {
        if (!isUserConfigured(user)) return emptyStream();
        try {
            String uri = "/api/greader.php/reader/api/0/stream/contents/user/-/state/com.google/reading-list"
                    + "?output=json"
                    + "&n=" + PAGE_SIZE
                    + "&xt=user/-/state/com.google/read"  // exclude already-read
                    + (continuation != null ? "&c=" + continuation : "");

            var result = restClient.get()
                    .uri(uri)
                    .header("Authorization", authHeader(user))
                    .retrieve()
                    .body(FreshRssStreamContents.class);
            return result != null ? result : emptyStream();
        } catch (RestClientException e) {
            logger.error("Failed to fetch FreshRSS stream for user {}: {}", user.getUsername(), e.getMessage());
            return emptyStream();
        }
    }

    /**
     * Marks the given FreshRSS item IDs as read in FreshRSS.
     * Batches the requests to avoid overly large POST bodies.
     *
     * @param user            the owning user
     * @param freshRssItemIds list of full tag URIs, e.g. "tag:google.com,2005:reader/item/..."
     */
    public void markAsRead(User user, List<String> freshRssItemIds) {
        if (!isUserConfigured(user) || freshRssItemIds.isEmpty()) return;
        try {
            String modToken = fetchModificationToken(user);
            // Batch into groups of MARK_READ_BATCH
            for (int i = 0; i < freshRssItemIds.size(); i += MARK_READ_BATCH) {
                List<String> batch = freshRssItemIds.subList(i, Math.min(i + MARK_READ_BATCH, freshRssItemIds.size()));
                MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
                form.add("T", modToken);
                form.add("a", "user/-/state/com.google/read");
                batch.forEach(id -> form.add("i", id));

                restClient.post()
                        .uri("/api/greader.php/reader/api/0/edit-tag")
                        .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                        .header("Authorization", authHeader(user))
                        .body(form)
                        .retrieve()
                        .toBodilessEntity();
            }
        } catch (RestClientException e) {
            logger.error("Failed to mark items as read in FreshRSS for user {}: {}", user.getUsername(), e.getMessage());
        }
    }

    // -----------------------------------------------------------------------
    // Internal helpers
    // -----------------------------------------------------------------------

    private String authHeader(User user) {
        return "GoogleLogin auth=" + getAuthToken(user);
    }

    /**
     * Returns a valid auth token for the user, re-authenticating if the cached token is expired.
     */
    private String getAuthToken(User user) {
        String cacheKey = user.getId();
        CachedToken cached = tokenCache.get(cacheKey);
        if (cached != null && !cached.isExpired()) {
            return cached.token();
        }

        logger.info("Authenticating user {} against FreshRSS", user.getUsername());
        MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("Email", user.getFreshRssUsername());
        form.add("Passwd", user.getFreshRssApiPassword());

        String body = restClient.post()
                .uri("/api/greader.php/accounts/ClientLogin")
                .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                .body(form)
                .retrieve()
                .body(String.class);

        String token = parseKeyValue(body, "Auth");
        if (token == null || token.isBlank()) {
            throw new IllegalStateException("FreshRSS auth failed for user " + user.getUsername() + ": no Auth token in response");
        }

        tokenCache.put(cacheKey, new CachedToken(token, System.currentTimeMillis() + TOKEN_TTL_MS));
        return token;
    }

    /**
     * Fetches a short-lived modification token required for POST write operations.
     */
    private String fetchModificationToken(User user) {
        return restClient.get()
                .uri("/api/greader.php/reader/api/0/token")
                .header("Authorization", authHeader(user))
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
     * Invalidates the cached auth token for a user (e.g. after credential change).
     */
    public void invalidateToken(String userId) {
        tokenCache.remove(userId);
    }
}
