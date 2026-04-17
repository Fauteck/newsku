package com.github.lamarios.newsku.models;

import java.math.BigDecimal;
import java.util.List;

/**
 * Aggregated OpenAI usage for one user + use case over a time window.
 *
 * @param useCase            which call the numbers cover
 * @param totalTokens        sum of prompt + completion tokens
 * @param promptTokens       sum of input tokens
 * @param completionTokens   sum of output tokens
 * @param estimatedCostUsd   optional cost estimate (null if unknown). Sum of
 *                           per-row stored cost plus per-model pricing
 *                           lookups from {@link com.github.lamarios.newsku.services.OpenAiPricing}.
 * @param callCount          number of calls that were recorded
 * @param monthlyLimit       the user's monthly limit for this use case (null if unset)
 * @param modelBreakdown     per-model aggregates so the UI can show which
 *                           model contributed how much cost / tokens
 */
public record OpenAiUsageStats(
        OpenAiUseCase useCase,
        long totalTokens,
        long promptTokens,
        long completionTokens,
        BigDecimal estimatedCostUsd,
        long callCount,
        Integer monthlyLimit,
        List<OpenAiModelUsage> modelBreakdown
) {
}
