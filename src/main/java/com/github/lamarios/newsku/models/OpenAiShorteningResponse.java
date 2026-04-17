package com.github.lamarios.newsku.models;

/**
 * Structured response for the text-shortening OpenAI call. Produces a
 * short headline variant and a teaser sentence suitable for compact card
 * layouts. Tracked independently from relevance scoring.
 */
public record OpenAiShorteningResponse(
        String shortTitle,
        String shortTeaser
) {
}
