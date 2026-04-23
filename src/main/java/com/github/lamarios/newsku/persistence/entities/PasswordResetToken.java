package com.github.lamarios.newsku.persistence.entities;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "password_reset_tokens")
public class PasswordResetToken {

    @Id
    @Column(name = "request_id", length = 36, nullable = false, updatable = false)
    private String requestId;

    @Column(name = "user_id", length = 36, nullable = false, updatable = false)
    private String userId;

    @Column(name = "expires_at", nullable = false, updatable = false)
    private Instant expiresAt;

    @Column(name = "used_at")
    private Instant usedAt;

    public PasswordResetToken() {}

    public PasswordResetToken(String requestId, String userId, Instant expiresAt) {
        this.requestId = requestId;
        this.userId = userId;
        this.expiresAt = expiresAt;
    }

    public String getRequestId() { return requestId; }
    public String getUserId() { return userId; }
    public Instant getExpiresAt() { return expiresAt; }
    public Instant getUsedAt() { return usedAt; }

    public boolean isExpired() { return Instant.now().isAfter(expiresAt); }
    public boolean isUsed() { return usedAt != null; }

    public void markUsed() { this.usedAt = Instant.now(); }
}
