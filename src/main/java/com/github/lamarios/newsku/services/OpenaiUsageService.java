package com.github.lamarios.newsku.services;

import com.github.lamarios.newsku.models.OpenAiModelUsage;
import com.github.lamarios.newsku.models.OpenAiUsageStats;
import com.github.lamarios.newsku.models.OpenAiUseCase;
import com.github.lamarios.newsku.models.OpenaiUsageEntryDto;
import com.github.lamarios.newsku.models.PageResponse;
import com.github.lamarios.newsku.models.UsageStatus;
import com.github.lamarios.newsku.persistence.entities.OpenaiUsage;
import com.github.lamarios.newsku.persistence.entities.User;
import com.github.lamarios.newsku.persistence.repositories.OpenaiUsageRepository;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.ZoneOffset;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.EnumMap;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Records every AI call (successful and failed), aggregates monthly usage and
 * enforces token limits configured on the user. Error entries keep the log
 * usable for diagnostics (e.g. wrong Ollama URL returning 404), but are not
 * counted against monthly token limits.
 */
@Service
public class OpenaiUsageService {

    private static final Logger logger = LogManager.getLogger();
    private static final String UNKNOWN_MODEL = "unknown";
    private static final int MAX_ERROR_MESSAGE_LENGTH = 2000;

    private final OpenaiUsageRepository repository;

    @Autowired
    public OpenaiUsageService(OpenaiUsageRepository repository) {
        this.repository = repository;
    }

    /**
     * Persists a successful call's token usage. Any exception is logged and
     * swallowed — a missing usage row must never block the sync.
     * Token parameters may be {@code null} when the provider's response did not
     * include a usage field (typical for some Ollama configurations).
     */
    @Transactional
    public void recordSuccess(User user,
                              OpenAiUseCase useCase,
                              String model,
                              Integer promptTokens,
                              Integer completionTokens,
                              Integer totalTokens,
                              Integer durationMs) {
        save(user, useCase, model,
                clampNonNegative(promptTokens),
                clampNonNegative(completionTokens),
                clampNonNegative(totalTokens),
                null,
                UsageStatus.OK,
                null,
                durationMs);
    }

    /**
     * Persists a failed call so the activity log shows it to the user. Error
     * rows never contribute to aggregated token counts or monthly limits.
     */
    @Transactional
    public void recordError(User user,
                            OpenAiUseCase useCase,
                            String model,
                            String errorMessage,
                            Integer durationMs) {
        save(user, useCase, model, null, null, null, null,
                UsageStatus.ERROR, truncate(errorMessage), durationMs);
    }

    private void save(User user,
                      OpenAiUseCase useCase,
                      String model,
                      Integer promptTokens,
                      Integer completionTokens,
                      Integer totalTokens,
                      BigDecimal estimatedCostUsd,
                      UsageStatus status,
                      String errorMessage,
                      Integer durationMs) {
        try {
            OpenaiUsage usage = new OpenaiUsage();
            usage.setId(UUID.randomUUID().toString());
            usage.setUser(user);
            usage.setUseCase(useCase);
            usage.setModel(model);
            usage.setPromptTokens(promptTokens);
            usage.setCompletionTokens(completionTokens);
            usage.setTotalTokens(totalTokens);
            usage.setEstimatedCostUsd(estimatedCostUsd);
            usage.setCreatedAt(System.currentTimeMillis());
            usage.setStatus(status);
            usage.setErrorMessage(errorMessage);
            usage.setDurationMs(durationMs);
            repository.save(usage);
        } catch (Exception e) {
            logger.warn("Failed to record OpenAI usage for user {} useCase {} status {}: {}",
                    user != null ? user.getUsername() : "null", useCase, status, e.getMessage());
        }
    }

    private static Integer clampNonNegative(Integer v) {
        if (v == null) return null;
        return Math.max(0, v);
    }

    private static String truncate(String s) {
        if (s == null) return null;
        return s.length() > MAX_ERROR_MESSAGE_LENGTH ? s.substring(0, MAX_ERROR_MESSAGE_LENGTH) : s;
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
        List<OpenaiUsage> rows = repository.findSuccessfulByUserAndCreatedAtBetween(user, from, to);

        Map<OpenAiUseCase, long[]> sums = new HashMap<>();
        Map<OpenAiUseCase, BigDecimal> costs = new HashMap<>();
        Map<OpenAiUseCase, Map<String, long[]>> perModel = new HashMap<>();
        Map<OpenAiUseCase, Map<String, BigDecimal>> perModelCosts = new HashMap<>();

        for (OpenaiUsage r : rows) {
            long total = nullableToLong(r.getTotalTokens());
            long prompt = nullableToLong(r.getPromptTokens());
            long completion = nullableToLong(r.getCompletionTokens());

            long[] agg = sums.computeIfAbsent(r.getUseCase(), k -> new long[]{0, 0, 0, 0});
            agg[0] += total;
            agg[1] += prompt;
            agg[2] += completion;
            agg[3] += 1;

            BigDecimal rowCost = r.getEstimatedCostUsd();
            if (rowCost == null) {
                rowCost = OpenAiPricing.estimate(r.getModel(), prompt, completion);
            }
            if (rowCost != null) {
                costs.merge(r.getUseCase(), rowCost, BigDecimal::add);
            }

            String modelKey = (r.getModel() == null || r.getModel().isBlank()) ? UNKNOWN_MODEL : r.getModel();
            Map<String, long[]> models = perModel.computeIfAbsent(r.getUseCase(), k -> new LinkedHashMap<>());
            long[] modelAgg = models.computeIfAbsent(modelKey, k -> new long[]{0, 0, 0, 0});
            modelAgg[0] += total;
            modelAgg[1] += prompt;
            modelAgg[2] += completion;
            modelAgg[3] += 1;

            if (rowCost != null) {
                Map<String, BigDecimal> modelCosts = perModelCosts.computeIfAbsent(r.getUseCase(), k -> new HashMap<>());
                modelCosts.merge(modelKey, rowCost, BigDecimal::add);
            }
        }

        Map<OpenAiUseCase, OpenAiUsageStats> result = new EnumMap<>(OpenAiUseCase.class);
        for (OpenAiUseCase useCase : OpenAiUseCase.values()) {
            long[] agg = sums.getOrDefault(useCase, new long[]{0, 0, 0, 0});
            Map<String, long[]> models = perModel.getOrDefault(useCase, Map.of());
            Map<String, BigDecimal> modelCosts = perModelCosts.getOrDefault(useCase, Map.of());

            List<OpenAiModelUsage> breakdown = new ArrayList<>(models.size());
            for (Map.Entry<String, long[]> e : models.entrySet()) {
                long[] m = e.getValue();
                breakdown.add(new OpenAiModelUsage(
                        e.getKey(),
                        m[0], m[1], m[2], m[3],
                        modelCosts.get(e.getKey())
                ));
            }
            breakdown.sort(Comparator.comparingLong(OpenAiModelUsage::totalTokens).reversed());

            result.put(useCase, new OpenAiUsageStats(
                    useCase,
                    agg[0],
                    agg[1],
                    agg[2],
                    costs.get(useCase),
                    agg[3],
                    monthlyLimit(user, useCase),
                    breakdown
            ));
        }
        return result;
    }

    private static long nullableToLong(Integer v) {
        return v == null ? 0L : v.longValue();
    }

    private static Integer monthlyLimit(User user, OpenAiUseCase useCase) {
        return switch (useCase) {
            case RELEVANCE -> user.getOpenAiMonthlyTokenLimitRelevance();
            case SHORTENING -> user.getOpenAiMonthlyTokenLimitShortening();
        };
    }

    /**
     * Returns paginated individual AI call log entries for the current user,
     * newest first. Includes both successful and failed calls so the user can
     * diagnose misconfiguration (e.g. wrong Ollama URL).
     */
    @Transactional(readOnly = true)
    public PageResponse<OpenaiUsageEntryDto> getLog(User user, int page, int size) {
        var pageRequest = PageRequest.of(page, size);
        var rows = repository.findByUserOrderByCreatedAtDesc(user, pageRequest);
        return PageResponse.of(rows.map(r -> new OpenaiUsageEntryDto(
                r.getId(),
                r.getUseCase().name(),
                r.getModel(),
                r.getPromptTokens(),
                r.getCompletionTokens(),
                r.getTotalTokens(),
                r.getEstimatedCostUsd(),
                r.getCreatedAt(),
                r.getStatus() != null ? r.getStatus().name() : UsageStatus.OK.name(),
                r.getErrorMessage(),
                r.getDurationMs()
        )));
    }

    /** Returns [startOfMonthMs, startOfNextMonthMs] in UTC. */
    static long[] currentMonthWindow() {
        ZonedDateTime now = ZonedDateTime.now(ZoneOffset.UTC);
        ZonedDateTime start = now.withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0).withNano(0);
        ZonedDateTime end = start.plusMonths(1);
        return new long[]{start.toInstant().toEpochMilli(), end.toInstant().toEpochMilli()};
    }
}
