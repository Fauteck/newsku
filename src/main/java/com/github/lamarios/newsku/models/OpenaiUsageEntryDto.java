package com.github.lamarios.newsku.models;

import java.math.BigDecimal;

public record OpenaiUsageEntryDto(
        String id,
        String useCase,
        String model,
        Integer promptTokens,
        Integer completionTokens,
        Integer totalTokens,
        BigDecimal estimatedCostUsd,
        long createdAt,
        String status,
        String errorMessage,
        Integer durationMs
) {}
