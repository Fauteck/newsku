package com.github.lamarios.newsku.models;

/**
 * Identifies which OpenAI call is being tracked / rate-limited.
 *
 * <ul>
 *   <li>{@code RELEVANCE} — importance scoring, ad detection, tags.</li>
 *   <li>{@code SHORTENING} — card-optimised shortTitle + shortTeaser.</li>
 * </ul>
 */
public enum OpenAiUseCase {
    RELEVANCE,
    SHORTENING
}
