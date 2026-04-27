package com.github.lamarios.newsku.controllers;

import com.github.lamarios.newsku.models.SyncStatus;
import com.github.lamarios.newsku.models.SyncStatusResponse;
import com.github.lamarios.newsku.persistence.entities.User;
import com.github.lamarios.newsku.services.UserService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/sync-status")
@Tag(name = "SyncStatus")
@SecurityRequirement(name = "bearerAuth")
public class SyncStatusController {

    private final UserService userService;

    public SyncStatusController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping
    public SyncStatusResponse getStatus() {
        User user = userService.getCurrentUser();
        SyncStatus status = user.getLastSyncStatus() != null ? user.getLastSyncStatus() : SyncStatus.NEVER_RUN;
        return new SyncStatusResponse(
                user.getLastSyncTime(),
                status,
                user.getLastSyncErrorMessage(),
                user.getLastSyncItemsAdded(),
                user.getLastSyncItemsUpdated()
        );
    }
}
