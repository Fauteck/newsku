package com.github.lamarios.newsku.models;

public record SyncStatusResponse(
        Long lastSyncTime,
        SyncStatus status,
        String errorMessage
) {
}
