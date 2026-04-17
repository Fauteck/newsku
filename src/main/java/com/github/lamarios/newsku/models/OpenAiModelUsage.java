package com.github.lamarios.newsku.models;

import java.math.BigDecimal;

/**
 * Per-model aggregate inside one use case, so the UI can break down "which
 * model cost how much". {@code estimatedCostUsd} is {@code null} when the
 * model is unknown to {@link com.github.lamarios.newsku.services.OpenAiPricing}.
 */
public record OpenAiModelUsage(
        String model,
        long totalTokens,
        long promptTokens,
        long completionTokens,
        long callCount,
        BigDecimal estimatedCostUsd
) {
}
