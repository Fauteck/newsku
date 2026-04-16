package com.github.lamarios.newsku.models;

import java.util.List;

/**
 * Structured response from the LLM for a feed item.
 *
 * <p>{@code shortTitle} and {@code shortTeaser} are AI-generated length-adapted
 * variants used when the global "text shortening" preference is enabled. They
 * are rewrites, not truncations, tailored to fit compact list/grid layouts.
 */
public record OpenAiFeedResponse(
        int importance,
        boolean possibleAd,
        String reasoning,
        List<String> tags,
        String shortTitle,
        String shortTeaser
) {
}
