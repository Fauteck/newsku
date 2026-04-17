package com.github.lamarios.newsku.services;

import com.github.lamarios.newsku.models.OpenAiUsageStats;
import com.github.lamarios.newsku.models.OpenAiUseCase;
import com.github.lamarios.newsku.persistence.entities.OpenaiUsage;
import com.github.lamarios.newsku.persistence.entities.User;
import com.github.lamarios.newsku.persistence.repositories.OpenaiUsageRepository;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.ZoneOffset;
import java.time.ZonedDateTime;
import java.util.EnumMap;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Records each OpenAI call, aggregates monthly usage and enforces token
 * limits configured on the user.
 */
@Service
public class OpenaiUsageService {

    private static final Logger logger = LogManager.getLogger();

    private final OpenaiUsageRepository repository;

    @Autowired
    public OpenaiUsageService(OpenaiUsageRepository repository) {
        this.repository = repository;
    }

    /**
     * Persists a single call's token usage. Any exception is logged and
     * swallowed — a missing usage row must never block the sync.
     */
    @Transactional
    public void record(User user,
                       OpenAiUseCase useCase,
                       String model,
                       int promptTokens,
                       int completionTokens,
                       int totalTokens,
                       BigDecimal estimatedCostUsd) {
        try {
            OpenaiUsage usage = new OpenaiUsage();
            usage.setId(UUID.randomUUID().toString());
            usage.setUser(user);
            usage.setUseCase(useCase);
            usage.setModel(model);
            usage.setPromptTokens(Math.max(0, promptTokens));
            usage.setCompletionTokens(Math.max(0, completionTokens));
            usage.setTotalTokens(Math.max(0, totalTokens));
            usage.setEstimatedCostUsd(estimatedCostUsd);
            usage.setCreatedAt(System.currentTimeMillis());
            repository.save(usage);
        } catch (Exception e) {
            logger.warn("Failed to record OpenAI usage for user {} useCase {}: {}",
                    user != null ? user.getUsername() : "null", useCase, e.getMessage());
        }
    }

    /**
     * True when the user has a monthly token limit configured for the given
     * use case and the sum of {@code totalTokens} in the current calendar
     * month (UTC) is already at or above that limit.
     */
    @Transactional(readOnly = true)
    public boolean isLimitExceeded(User user, OpenAiUseCase useCase) {
        Integer limit = monthlyLimit(user, useCase);
        if (limit == null || limit <= 0) {
            return false;
        }
        long[] window = currentMonthWindow();
        long used = repository.sumTotalTokens(user, useCase, window[0], window[1]);
        return used >= limit;
    }

    /**
     * Returns current-month stats per use case. Every use case is present in
     * the result, with zeroes when no calls were made.
     */
    @Transactional(readOnly = true)
    public Map<OpenAiUseCase, OpenAiUsageStats> getMonthlyUsage(User user) {
        long[] window = currentMonthWindow();
        return aggregate(user, window[0], window[1]);
    }

    /**
     * Aggregated stats for an arbitrary window. Used by the usage controller.
     */
    @Transactional(readOnly = true)
    public Map<OpenAiUseCase, OpenAiUsageStats> getUsage(User user, long fromMs, long toMs) {
        return aggregate(user, fromMs, toMs);
    }

    private Map<OpenAiUseCase, OpenAiUsageStats> aggregate(User user, long from, long to) {
        List<OpenaiUsage> rows = repository.findByUserAndCreatedAtBetween(user, from, to);
        Map<OpenAiUseCase, long[]> sums = new HashMap<>();
        Map<OpenAiUseCase, BigDecimal> costs = new HashMap<>();
        for (OpenaiUsage r : rows) {
            long[] agg = sums.computeIfAbsent(r.getUseCase(), k -> new long[]{0, 0, 0, 0});
            agg[0] += r.getTotalTokens();
            agg[1] += r.getPromptTokens();
            agg[2] += r.getCompletionTokens();
            agg[3] += 1;
            if (r.getEstimatedCostUsd() != null) {
                costs.merge(r.getUseCase(), r.getEstimatedCostUsd(), BigDecimal::add);
            }
        }
        Map<OpenAiUseCase, OpenAiUsageStats> result = new EnumMap<>(OpenAiUseCase.class);
        for (OpenAiUseCase useCase : OpenAiUseCase.values()) {
            long[] agg = sums.getOrDefault(useCase, new long[]{0, 0, 0, 0});
            result.put(useCase, new OpenAiUsageStats(
                    useCase,
                    agg[0],
                    agg[1],
                    agg[2],
                    costs.get(useCase),
                    agg[3],
                    monthlyLimit(user, useCase)
            ));
        }
        return result;
    }

    private static Integer monthlyLimit(User user, OpenAiUseCase useCase) {
        return switch (useCase) {
            case RELEVANCE -> user.getOpenAiMonthlyTokenLimitRelevance();
            case SHORTENING -> user.getOpenAiMonthlyTokenLimitShortening();
        };
    }

    /** Returns [startOfMonthMs, startOfNextMonthMs] in UTC. */
    static long[] currentMonthWindow() {
        ZonedDateTime now = ZonedDateTime.now(ZoneOffset.UTC);
        ZonedDateTime start = now.withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0).withNano(0);
        ZonedDateTime end = start.plusMonths(1);
        return new long[]{start.toInstant().toEpochMilli(), end.toInstant().toEpochMilli()};
    }
}
