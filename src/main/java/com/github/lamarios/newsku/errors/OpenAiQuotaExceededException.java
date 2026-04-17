package com.github.lamarios.newsku.errors;

/**
 * Signals that the OpenAI API returned a 429 indicating the configured
 * API key has run out of quota or is being rate-limited. Thrown from the
 * OpenAI retry loop to abort the current sync cycle instead of hammering
 * the API for every remaining item.
 */
public class OpenAiQuotaExceededException extends NewskuException {
    public OpenAiQuotaExceededException(String message) {
        super(message);
    }
}
