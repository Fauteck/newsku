package com.github.lamarios.newsku.models;

import java.math.BigDecimal;

public record OpenaiUsageEntryDto(
        String id,
        String useCase,
        String model,
        int promptTokens,
        int completionTokens,
        int totalTokens,
        BigDecimal estimatedCostUsd,
        long createdAt
) {}
