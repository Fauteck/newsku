package com.github.lamarios.newsku.services;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Guards the detection helper that turns a generic OpenAI SDK exception into
 * a quota-abort signal. The helper must recognise the 429 shapes we observe
 * in production logs ({@code "429: You exceeded your current quota..."}) and
 * must NOT trip on unrelated errors (HTTP 5xx, network failures).
 */
class OpenaiServiceImplQuotaTest {

    @Test
    void detects429PrefixInMessage() {
        assertTrue(OpenaiServiceImpl.isQuotaOrRateLimit(
                new RuntimeException("429: You exceeded your current quota, please check your plan")));
    }

    @Test
    void detectsInsufficientQuotaCode() {
        assertTrue(OpenaiServiceImpl.isQuotaOrRateLimit(
                new RuntimeException("insufficient_quota")));
    }

    @Test
    void detectsQuotaMessageWithoutStatusPrefix() {
        assertTrue(OpenaiServiceImpl.isQuotaOrRateLimit(
                new RuntimeException("You exceeded your current quota, please check your plan and billing details.")));
    }

    @Test
    void detectsQuotaInWrappedCause() {
        RuntimeException inner = new RuntimeException("429: You exceeded your current quota");
        RuntimeException outer = new RuntimeException("wrapper failure", inner);
        assertTrue(OpenaiServiceImpl.isQuotaOrRateLimit(outer));
    }

    @Test
    void ignoresServerError() {
        assertFalse(OpenaiServiceImpl.isQuotaOrRateLimit(
                new RuntimeException("500: internal server error")));
    }

    @Test
    void ignoresNetworkFailure() {
        assertFalse(OpenaiServiceImpl.isQuotaOrRateLimit(
                new RuntimeException("connection reset")));
    }

    @Test
    void detects429WithNullBody() {
        // Google Gemini OpenAI-compat endpoint returns 429 with no body;
        // the SDK reports it as "429: null" — must still be detected.
        assertTrue(OpenaiServiceImpl.isQuotaOrRateLimit(
                new RuntimeException("429: null")));
    }

    @Test
    void ignoresNullMessage() {
        assertFalse(OpenaiServiceImpl.isQuotaOrRateLimit(new RuntimeException()));
    }

    @Test
    void ignoresNullThrowable() {
        assertFalse(OpenaiServiceImpl.isQuotaOrRateLimit(null));
    }
}
