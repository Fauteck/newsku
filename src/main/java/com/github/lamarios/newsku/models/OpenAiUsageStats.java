package com.github.lamarios.newsku.models;

import java.math.BigDecimal;

/**
 * Aggregated OpenAI usage for one user + use case over a time window.
 *
 * @param useCase        which call the numbers cover
 * @param totalTokens    sum of prompt + completion tokens
 * @param promptTokens   sum of input tokens
 * @param completionTokens sum of output tokens
 * @param estimatedCostUsd optional cost estimate (null if unknown)
 * @param callCount      number of calls that were recorded
 * @param monthlyLimit   the user's monthly limit for this use case (null if unset)
 */
public record OpenAiUsageStats(
        OpenAiUseCase useCase,
        long totalTokens,
        long promptTokens,
        long completionTokens,
        BigDecimal estimatedCostUsd,
        long callCount,
        Integer monthlyLimit
) {
}
