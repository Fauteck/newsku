package com.github.lamarios.newsku.utils;

import jakarta.servlet.FilterChain;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

public class CacheControlFilterTest {

    private final CacheControlFilter filter = new CacheControlFilter();

    @Test
    public void imageEndpoint_getsImmutableLongCache() throws Exception {
        var response = run("GET", "/api/feeds/items/abc123/image");
        assertEquals("public, max-age=604800, immutable", response.getHeader("Cache-Control"));
        assertNull(response.getHeader("Vary"));
    }

    @Test
    public void feedImageEndpoint_getsImmutableLongCache() throws Exception {
        var response = run("GET", "/api/feeds/feed-id/image");
        assertEquals("public, max-age=604800, immutable", response.getHeader("Cache-Control"));
    }

    @Test
    public void feedListEndpoint_getsShortPrivateCache_andVary() throws Exception {
        var response = run("GET", "/api/feeds");
        assertEquals("private, max-age=60", response.getHeader("Cache-Control"));
        assertEquals("Authorization", response.getHeader("Vary"));
    }

    @Test
    public void itemListEndpoint_getsShortPrivateCache() throws Exception {
        var response = run("GET", "/api/feeds/items");
        assertEquals("private, max-age=60", response.getHeader("Cache-Control"));
        assertEquals("Authorization", response.getHeader("Vary"));
    }

    @Test
    public void savedListEndpoint_getsShortPrivateCache() throws Exception {
        var response = run("GET", "/api/feeds/items/saved");
        assertEquals("private, max-age=60", response.getHeader("Cache-Control"));
    }

    @Test
    public void otherApiEndpoints_defaultToNoStore() throws Exception {
        var response = run("GET", "/api/sync-status");
        assertEquals("no-store", response.getHeader("Cache-Control"));
    }

    @Test
    public void mutatingRequests_areLeftAlone() throws Exception {
        var response = run("POST", "/api/feeds/items/read");
        assertNull(response.getHeader("Cache-Control"));
    }

    @Test
    public void nonApiPath_isLeftAlone() throws Exception {
        var response = run("GET", "/some-static-asset.js");
        assertNull(response.getHeader("Cache-Control"));
    }

    private MockHttpServletResponse run(String method, String uri) throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest(method, uri);
        MockHttpServletResponse response = new MockHttpServletResponse();
        FilterChain chain = (req, res) -> { /* no-op */ };
        filter.doFilter(request, response, chain);
        return response;
    }
}
