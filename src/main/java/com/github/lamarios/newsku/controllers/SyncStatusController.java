package com.github.lamarios.newsku.controllers;

import com.github.lamarios.newsku.models.SyncStatus;
import com.github.lamarios.newsku.models.SyncStatusResponse;
import com.github.lamarios.newsku.persistence.entities.User;
import com.github.lamarios.newsku.services.UserService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/sync-status")
@Tag(name = "SyncStatus")
@SecurityRequirement(name = "bearerAuth")
public class SyncStatusController {

    private final UserService userService;
    private final long staleThresholdMs;

    public SyncStatusController(
            UserService userService,
            @Value("${newsku.sync.stale-threshold-minutes:40}") long staleThresholdMinutes) {
        this.userService = userService;
        this.staleThresholdMs = Math.max(0L, staleThresholdMinutes) * 60_000L;
    }

    @GetMapping
    public SyncStatusResponse getStatus() {
        User user = userService.getCurrentUser();
        SyncStatus status = user.getLastSyncStatus() != null ? user.getLastSyncStatus() : SyncStatus.NEVER_RUN;
        String errorMessage = user.getLastSyncErrorMessage();

        // Read-side derivation: a RUNNING sync that hasn't updated its
        // lastSyncTime within the configured window is treated as stale and
        // surfaced as FAILED so the UI can prompt for a manual retry. The
        // stored row is left untouched, preserving the original status.
        if (status == SyncStatus.RUNNING && user.getLastSyncTime() != null
                && (System.currentTimeMillis() - user.getLastSyncTime()) > staleThresholdMs) {
            status = SyncStatus.FAILED;
            long minutes = staleThresholdMs / 60_000L;
            errorMessage = "Sync stale (no progress in over " + minutes + " min)";
        }

        return new SyncStatusResponse(
                user.getLastSyncTime(),
                status,
                errorMessage,
                user.getLastSyncItemsAdded(),
                user.getLastSyncItemsUpdated()
        );
    }
}
