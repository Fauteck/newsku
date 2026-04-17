package com.github.lamarios.newsku.models;

import java.util.List;

/**
 * Structured response for the relevance-scoring OpenAI call (importance,
 * ad detection, tagging). Kept separate from the shortening response so each
 * call can be tracked and rate-limited independently.
 */
public record OpenAiRelevanceResponse(
        int importance,
        boolean possibleAd,
        String reasoning,
        List<String> tags
) {
}
