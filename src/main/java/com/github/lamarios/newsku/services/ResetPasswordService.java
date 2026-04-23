package com.github.lamarios.newsku.services;

import com.github.lamarios.newsku.persistence.entities.User;
import com.github.lamarios.newsku.persistence.repositories.UserRepository;
import com.github.lamarios.newsku.security.JwtTokenUtil;
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
import java.util.HashMap;
import java.util.Map;
import java.util.Random;
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
    private final JwtTokenUtil jwtTokenUtil;
    private final String rootUrl;
    private final EmailService emailService;
    private final PasswordEncoder passwordEncoder;

    @Autowired
    public ResetPasswordService(UserRepository userRepository, JwtTokenUtil jwtTokenUtil, String rootUrl, EmailService emailService, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.jwtTokenUtil = jwtTokenUtil;
        this.rootUrl = rootUrl;
        this.emailService = emailService;
        this.passwordEncoder = passwordEncoder;
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

            String token = jwtTokenUtil.doGenerateToken(Map.of("type", "reset-password", "request-id", UUID.randomUUID()
                    .toString(), "server-url", rootUrl), user.getId(), RESET_PASSOWRD_EXPIRY);

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
            User user = userRepository.findFirstById(claims.getSubject());

            if (user == null) {
                throw new InvalidParameterException("Invalid token");
            }

            user.setPassword(passwordEncoder.encode(password));

            userRepository.save(user);

        } catch (SignatureException e) {
            throw new InvalidParameterException("Invalid token");
        }


    }
}