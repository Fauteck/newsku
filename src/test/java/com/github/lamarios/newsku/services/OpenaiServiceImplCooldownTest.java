package com.github.lamarios.newsku.services;

import com.github.lamarios.newsku.persistence.entities.User;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;

/**
 * Guards the per-user quota cooldown that short-circuits further OpenAI
 * calls after a 429. Without this, a single 429 used to abort the entire
 * FreshRSS sync for hours on end (see GReaderSyncService).
 */
class OpenaiServiceImplCooldownTest {

    private OpenaiServiceImpl newService(long cooldownMinutes) {
        return new OpenaiServiceImpl(
                "http://localhost",
                "key",
                "model",
                1,
                1L,
                cooldownMinutes,
                mock(OpenaiUsageService.class));
    }

    private static User user(String id) {
        User u = new User();
        u.setId(id);
        u.setUsername("user-" + id);
        return u;
    }

    @Test
    void cooldownInactiveByDefault() {
        OpenaiServiceImpl svc = newService(60);
        assertFalse(svc.isInQuotaCooldown(user("u1")));
    }

    @Test
    void enterActivatesCooldown() {
        OpenaiServiceImpl svc = newService(60);
        User u = user("u1");
        svc.enterQuotaCooldown(u);
        assertTrue(svc.isInQuotaCooldown(u));
    }

    @Test
    void cooldownIsPerUser() {
        OpenaiServiceImpl svc = newService(60);
        svc.enterQuotaCooldown(user("u1"));
        assertFalse(svc.isInQuotaCooldown(user("u2")));
    }

    @Test
    void zeroMinuteCooldownIsNeverActive() {
        // Defensive: a misconfigured 0-minute cooldown must not freeze all AI
        // calls; enterQuotaCooldown should be a no-op.
        OpenaiServiceImpl svc = newService(0);
        User u = user("u1");
        svc.enterQuotaCooldown(u);
        assertFalse(svc.isInQuotaCooldown(u));
    }
}
