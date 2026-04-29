package com.github.lamarios.newsku.controllers;

import com.github.lamarios.newsku.TestConfig;
import com.github.lamarios.newsku.TestContainerTest;
import com.github.lamarios.newsku.models.SyncStatus;
import com.github.lamarios.newsku.persistence.entities.User;
import com.github.lamarios.newsku.persistence.repositories.UserRepository;
import com.github.lamarios.newsku.services.UserService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

@Import(TestConfig.class)
public class SyncStatusControllerTest extends TestContainerTest {

    @Autowired
    private SyncStatusController syncStatusController;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserService userService;

    @Test
    public void freshUser_reportsNeverRun() {
        var response = syncStatusController.getStatus();
        assertEquals(SyncStatus.NEVER_RUN, response.status());
        assertNull(response.lastSyncTime());
        assertNull(response.errorMessage());
    }

    @Test
    public void runningSync_olderThanThreshold_reportsStale() {
        User user = userService.getCurrentUser();
        user.setLastSyncStatus(SyncStatus.RUNNING);
        user.setLastSyncTime(System.currentTimeMillis() - 50L * 60_000L);
        userRepository.save(user);

        var response = syncStatusController.getStatus();
        assertEquals(SyncStatus.FAILED, response.status());
        assertNotNull(response.errorMessage());
        assertTrue(response.errorMessage().toLowerCase().contains("stale"),
                "Expected stale message, got: " + response.errorMessage());
    }

    @Test
    public void runningSync_recentProgress_staysRunning() {
        User user = userService.getCurrentUser();
        user.setLastSyncStatus(SyncStatus.RUNNING);
        user.setLastSyncTime(System.currentTimeMillis() - 60_000L);
        userRepository.save(user);

        var response = syncStatusController.getStatus();
        assertEquals(SyncStatus.RUNNING, response.status());
    }
}
