package com.github.lamarios.newsku.services;

import com.github.lamarios.newsku.persistence.entities.PasswordResetToken;
import com.github.lamarios.newsku.persistence.entities.User;
import com.github.lamarios.newsku.persistence.repositories.PasswordResetTokenRepository;
import com.github.lamarios.newsku.persistence.repositories.UserRepository;
import com.github.lamarios.newsku.security.JwtTokenUtil;
import com.github.lamarios.newsku.security.SecurityAuditLogger;
import freemarker.template.TemplateException;
import io.jsonwebtoken.security.SignatureException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.security.InvalidParameterException;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
public class ResetPasswordService {

    private static final Logger logger = LogManager.getLogger();

    // Target wall-clock time for forgot-password responses. Pads every branch
    // (existing email, unknown email, template/mail failure) to the same wall
    // clock so attackers cannot enumerate registered addresses via timing.
    private static final long FORGOT_TARGET_MS = 1500L;

    public static final int RESET_PASSOWRD_EXPIRY = 24 * 60 * 60 * 1000;
    private final UserRepository userRepository;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final JwtTokenUtil jwtTokenUtil;
    private final String rootUrl;
    private final EmailService emailService;
    private final PasswordEncoder passwordEncoder;
    private final SecurityAuditLogger auditLogger;

    @Autowired
    public ResetPasswordService(UserRepository userRepository, PasswordResetTokenRepository passwordResetTokenRepository, JwtTokenUtil jwtTokenUtil, String rootUrl, EmailService emailService, PasswordEncoder passwordEncoder, SecurityAuditLogger auditLogger) {
        this.userRepository = userRepository;
        this.passwordResetTokenRepository = passwordResetTokenRepository;
        this.jwtTokenUtil = jwtTokenUtil;
        this.rootUrl = rootUrl;
        this.emailService = emailService;
        this.passwordEncoder = passwordEncoder;
        this.auditLogger = auditLogger;
    }

    @Transactional(readOnly = true)
    public void forgotPassword(String email) throws TemplateException, IOException {
        long start = System.nanoTime();
        try {
            User user = userRepository.findFirstByEmail(email);

            if (user == null) {
                // Intentionally silent: the caller returns a generic "Falls die
                // Adresse existiert, wurde eine Mail versendet"-response so no
                // information about user existence leaks in the response body.
                return;
            }

            auditLogger.passwordResetRequested(user.getId());
            String requestId = UUID.randomUUID().toString();
            Instant expiresAt = Instant.now().plusMillis(RESET_PASSOWRD_EXPIRY);
            passwordResetTokenRepository.save(new PasswordResetToken(requestId, user.getId(), expiresAt));

            String token = jwtTokenUtil.doGenerateToken(Map.of("type", "reset-password", "request-id", requestId,
                    "server-url", rootUrl), user.getId(), RESET_PASSOWRD_EXPIRY);

            Map<String, Object> templateData = new HashMap<>();

            String resetPasswordUrl = rootUrl + "/#/reset-password?token=" + token;
            templateData.put("url", resetPasswordUrl);
            templateData.put("username", user.getUsername());

            try {
                emailService.sendTemplate(user.getEmail(), "[Newsku] Reset password request", "email/reset-password.ftl", templateData);
            } catch (Exception e) {
                // Mail failures must not leak via timing or an exception response,
                // otherwise an attacker can distinguish "known email, mailer broken"
                // from "unknown email, silent no-op".
                logger.error("Could not send reset-password mail for known user", e);
            }
        } finally {
            long elapsedMs = (System.nanoTime() - start) / 1_000_000L;
            long remaining = FORGOT_TARGET_MS - elapsedMs;
            if (remaining > 0) {
                try {
                    Thread.sleep(remaining);
                } catch (InterruptedException _) {
                    Thread.currentThread().interrupt();
                }
            }
        }
    }

    @Transactional()
    public void resetPassword(String token, String password) {
        try {
            var claims = jwtTokenUtil.getAllClaimsFromToken(token);
            String requestId = (String) claims.get("request-id");
            User user = userRepository.findFirstById(claims.getSubject());

            if (user == null) {
                auditLogger.passwordResetTokenInvalid("user not found");
                throw new InvalidParameterException("Invalid token");
            }

            PasswordResetToken dbToken = requestId != null
                    ? passwordResetTokenRepository.findById(requestId).orElse(null)
                    : null;

            if (dbToken == null || dbToken.isExpired() || dbToken.isUsed()) {
                auditLogger.passwordResetTokenInvalid(dbToken == null ? "not found in db"
                        : dbToken.isExpired() ? "expired" : "already used");
                throw new InvalidParameterException("Invalid or expired token");
            }

            dbToken.markUsed();
            passwordResetTokenRepository.save(dbToken);

            user.setPassword(passwordEncoder.encode(password));
            userRepository.save(user);
            auditLogger.passwordResetCompleted(user.getId());

        } catch (SignatureException e) {
            auditLogger.passwordResetTokenInvalid("invalid signature");
            throw new InvalidParameterException("Invalid token");
        }
    }
}