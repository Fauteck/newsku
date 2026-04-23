package com.github.lamarios.newsku.security;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Component;

/**
 * Structured logger for security-relevant events.
 * Uses a dedicated "security-audit" logger so audit records can be routed
 * to a separate appender / SIEM without changing business-logic code.
 */
@Component
public class SecurityAuditLogger {

    private static final Logger audit = LogManager.getLogger("security-audit");

    public void loginRateLimitExceeded(String ip, int attempts, long windowMs) {
        audit.warn("event=RATE_LIMIT_EXCEEDED ip={} attempts={} windowMs={}", ip, attempts, windowMs);
    }

    public void loginFailed(String username, String ip) {
        audit.warn("event=LOGIN_FAILED username={} ip={}", username, ip);
    }

    public void loginSuccess(String username, String ip) {
        audit.info("event=LOGIN_SUCCESS username={} ip={}", username, ip);
    }

    public void passwordResetRequested(String userId) {
        audit.info("event=PASSWORD_RESET_REQUESTED userId={}", userId);
    }

    public void passwordResetCompleted(String userId) {
        audit.info("event=PASSWORD_RESET_COMPLETED userId={}", userId);
    }

    public void passwordResetTokenInvalid(String reason) {
        audit.warn("event=PASSWORD_RESET_TOKEN_INVALID reason={}", reason);
    }
}
