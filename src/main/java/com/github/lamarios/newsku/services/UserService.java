package com.github.lamarios.newsku.services;

import com.github.lamarios.newsku.errors.NewskuUserException;
import com.github.lamarios.newsku.persistence.entities.User;
import com.github.lamarios.newsku.persistence.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.SQLException;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.Objects;
import java.util.Optional;
import java.util.UUID;

@Service
public class UserService {

    private final UserRepository userRepository;

    private final PasswordEncoder passwordEncoder;

    private final static String EMAIL_REGEX = "[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?";

    @Autowired
    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    // Short-TTL cache keyed on username. Every authenticated request resolves
    // the same user — the request chain triggers this dozens of times.
    @Cacheable(value = "users", unless = "#result == null || !#result.isPresent()")
    @Transactional(readOnly = true)
    public Optional<User> getUser(String username) {
        return userRepository.getUserByUsername(username).stream().findFirst();
    }


    @Transactional(readOnly = true)
    public User getCurrentUser() {
        final Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null) {
            throw new AccessDeniedException("No authenticated user in security context");
        }
        Object principal = authentication.getPrincipal();
        if (!(principal instanceof org.springframework.security.core.userdetails.User user)) {
            throw new AccessDeniedException("Unexpected authentication principal");
        }
        return getUser(user.getUsername()).orElseThrow();
    }

    // Target wall-clock time for signup responses (both success and failure).
    // Every path is padded to this constant so response-time attacks can no
    // longer distinguish "email known" vs. "email new". 2000 ms roughly matches
    // the cost of a BCrypt hash on a typical server.
    private static final long SIGNUP_TARGET_MS = 2000L;

    private static void padToConstantTime(long startNanos, long targetMs) {
        long elapsedMs = (System.nanoTime() - startNanos) / 1_000_000L;
        long remaining = targetMs - elapsedMs;
        if (remaining > 0) {
            try {
                Thread.sleep(remaining);
            } catch (InterruptedException _) {
                Thread.currentThread().interrupt();
            }
        }
    }

    @Transactional
    public User createUser(User user) throws NewskuUserException {
        long start = System.nanoTime();
        user.setId(UUID.randomUUID().toString());

        try {
            boolean emailUsed = userRepository.countUserByEmail(user.getEmail()) > 0;
            boolean usernameUsed = userRepository.countUserByUsername(user.getUsername()) > 0;

            if (emailUsed) {
                throw new NewskuUserException("Email already taken");
            }

            if (usernameUsed) {
                throw new NewskuUserException("Username already taken");
            }

            if (!user.getEmail().matches(EMAIL_REGEX)) {
                throw new NewskuUserException("Invalid email address");
            }

            // hash password
            if (user.getPassword() != null) {
                user.setPassword(passwordEncoder.encode(user.getPassword()));
            }

            return userRepository.save(user);
        } finally {
            padToConstantTime(start, SIGNUP_TARGET_MS);
        }
    }

    public Optional<User> getByOidcSub(String sub) {
        return Optional.ofNullable(userRepository.getUserByOidcSub(sub));
    }

    private static long startOfTodayUtcMs() {
        return Instant.now().atZone(ZoneOffset.UTC).toLocalDate()
                .atStartOfDay(ZoneOffset.UTC).toInstant().toEpochMilli();
    }

    static String normaliseOpenAiUrl(String url) {
        if (url == null) return null;
        String trimmed = url.trim();
        if (trimmed.isEmpty()) return trimmed;
        while (trimmed.endsWith("/")) {
            trimmed = trimmed.substring(0, trimmed.length() - 1);
        }
        return trimmed;
    }

    @CacheEvict(value = "users", key = "#user.username")
    public User updateUser(User user) {
        return userRepository.save(user);
    }

    // Evict the short-TTL user cache whenever the user mutates via self-edit.
    // updateUser() has the same @CacheEvict, but the internal call below
    // bypasses Spring's AOP proxy, so the annotation has to live here too.
    @Transactional
    @CacheEvict(value = "users", key = "#user.username")
    public User updateSelf(User user) throws NewskuUserException {
        User currentUser = getCurrentUser();
        if (currentUser.getId().equalsIgnoreCase(user.getId())) {
            // we update the password if it has changed
            if (user.getPassword() != null && !user.getPassword().trim().isBlank() && !currentUser.getPassword()
                    .equalsIgnoreCase(user.getPassword())) {
                user.setPassword(passwordEncoder.encode(user.getPassword()));
            } else {
                user.setPassword(currentUser.getPassword());
            }

            if (!Objects.equals(user.getEmail(), currentUser.getEmail())) {

                if (user.getEmail().matches(EMAIL_REGEX)) {
                    var alreadyTaken = userRepository.countUserByEmail(user.getEmail()) > 0;
                    if (alreadyTaken) {
                        throw new NewskuUserException("Email already in use");
                    }
                } else {
                    throw new NewskuUserException("Invalid email address");
                }

            }

            // Keep existing GReader API password when the frontend sends a blank value
            // (the UI intentionally clears the password field after a save).
            if (user.getGReaderApiPassword() == null || user.getGReaderApiPassword().isBlank()) {
                user.setGReaderApiPassword(currentUser.getGReaderApiPassword());
            }

            // Normalise the OpenAI base URL: trim whitespace and strip any trailing
            // slashes. The OpenAI SDK builds request URLs by appending "/chat/completions"
            // etc., so a trailing slash produces a double slash and some gateways
            // (Ollama via reverse proxy, Cloudflare) reject that.
            user.setOpenAiUrl(normaliseOpenAiUrl(user.getOpenAiUrl()));

            // Detect first-time AI configuration (check BEFORE the API-key preservation
            // below so we can see the raw incoming value from the client).
            // On a fresh installation the user sets an API key (OpenAI) or a custom URL
            // (Ollama / self-hosted). We record the start of today (UTC) so that the sync
            // engine only applies AI scoring to articles published from that day onward,
            // avoiding a bulk-scoring of all historical articles on first import.
            if (currentUser.getAiEnabledSince() != null) {
                // Already configured – preserve the recorded timestamp.
                user.setAiEnabledSince(currentUser.getAiEnabledSince());
            } else {
                boolean settingKey = user.getOpenAiApiKey() != null && !user.getOpenAiApiKey().isBlank();
                boolean settingUrl = user.getOpenAiUrl() != null && !user.getOpenAiUrl().isBlank()
                        && (currentUser.getOpenAiUrl() == null || currentUser.getOpenAiUrl().isBlank());
                if (settingKey || settingUrl) {
                    user.setAiEnabledSince(startOfTodayUtcMs());
                }
            }

            // Same for the OpenAI API key — never returned to the client, so a
            // blank value on update means "keep existing".
            if (user.getOpenAiApiKey() == null || user.getOpenAiApiKey().isBlank()) {
                user.setOpenAiApiKey(currentUser.getOpenAiApiKey());
            }

            // enableAi is a NOT NULL column — if an older client omits it we
            // preserve the current setting instead of letting Hibernate reject
            // the update.
            if (user.getEnableAi() == null) {
                user.setEnableAi(currentUser.getEnableAi());
            }

            return updateUser(user);
        } else {
            throw new AccessDeniedException("You can only edit yourself");
        }
    }
}
