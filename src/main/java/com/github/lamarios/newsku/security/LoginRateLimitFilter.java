package com.github.lamarios.newsku.security;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Limits login attempts per IP to prevent brute-force attacks.
 * Allows at most MAX_ATTEMPTS requests within a sliding WINDOW_MS window.
 */
@Component
public class LoginRateLimitFilter implements Filter {

    private static final Logger logger = LogManager.getLogger();

    @Value("${LOGIN_RATE_LIMIT_MAX_ATTEMPTS:10}")
    private int maxAttempts;

    @Value("${LOGIN_RATE_LIMIT_WINDOW_MS:60000}")
    private long windowMs;

    private static final String LOGIN_PATH = "/login";

    private record AttemptWindow(AtomicInteger count, long windowStart) {}

    private final ConcurrentHashMap<String, AttemptWindow> attempts = new ConcurrentHashMap<>();

    @Autowired
    private SecurityAuditLogger auditLogger;

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        if ("POST".equalsIgnoreCase(httpRequest.getMethod())
                && LOGIN_PATH.equals(httpRequest.getRequestURI())) {

            String ip = getClientIp(httpRequest);
            long now = System.currentTimeMillis();

            AttemptWindow window = attempts.compute(ip, (key, existing) -> {
                if (existing == null || now - existing.windowStart() >= windowMs) {
                    return new AttemptWindow(new AtomicInteger(1), now);
                }
                existing.count().incrementAndGet();
                return existing;
            });

            if (window.count().get() > maxAttempts) {
                auditLogger.loginRateLimitExceeded(ip, window.count().get(), windowMs);
                httpResponse.setStatus(429);
                httpResponse.setContentType("application/json");
                httpResponse.getWriter().write(
                        "{\"error\":\"Too many login attempts. Please try again later.\"}");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    private String getClientIp(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isBlank()) {
            // Take only the first (client) IP from a potential proxy chain
            return xForwardedFor.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
