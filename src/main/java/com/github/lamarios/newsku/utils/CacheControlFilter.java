package com.github.lamarios.newsku.utils;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * F8: Adds HTTP cache hints to read-heavy endpoints so browsers and the Flutter app
 * stop refetching identical payloads on tab switches and image scrolls.
 *
 * <ul>
 *   <li>Image endpoints get {@code public, max-age=7d, immutable}: the resource at
 *       a given URL never changes content, so the browser never needs to revalidate.</li>
 *   <li>List endpoints get {@code private, max-age=60} plus {@code Vary: Authorization}:
 *       per-user content, cached briefly client-side, never shared across users.</li>
 * </ul>
 *
 * Only GET requests are touched; mutating verbs are left alone.
 */
@Component
public class CacheControlFilter extends OncePerRequestFilter {

    private static final String IMAGE_CACHE = "public, max-age=604800, immutable";
    private static final String LIST_CACHE = "private, max-age=60";
    private static final String DEFAULT_API_CACHE = "no-store";

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {

        if ("GET".equalsIgnoreCase(request.getMethod())) {
            String path = request.getRequestURI();
            if (isImagePath(path)) {
                response.setHeader(HttpHeaders.CACHE_CONTROL, IMAGE_CACHE);
            } else if (isListPath(path)) {
                response.setHeader(HttpHeaders.CACHE_CONTROL, LIST_CACHE);
                response.setHeader(HttpHeaders.VARY, HttpHeaders.AUTHORIZATION);
            } else if (path != null && path.startsWith("/api/")) {
                // Spring Security's default cacheControl HeaderWriter is disabled
                // (see WebSecurityConfig); ensure all non-allowlisted API GETs
                // remain uncached so user-specific responses never bleed across
                // sessions in shared browser caches.
                response.setHeader(HttpHeaders.CACHE_CONTROL, DEFAULT_API_CACHE);
            }
        }
        chain.doFilter(request, response);
    }

    private static boolean isImagePath(String path) {
        if (path == null) return false;
        return path.endsWith("/image")
                && (path.startsWith("/api/feeds/items/") || path.startsWith("/api/feeds/"));
    }

    private static boolean isListPath(String path) {
        if (path == null) return false;
        if (path.equals("/api/feeds")) return true;
        if (path.equals("/api/feeds/items")) return true;
        if (path.equals("/api/feeds/items/saved")) return true;
        if (path.equals("/api/feeds/items/saved/page")) return true;
        return false;
    }
}
