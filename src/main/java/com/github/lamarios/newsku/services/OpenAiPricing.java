package com.github.lamarios.newsku.services;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Static price table for common OpenAI models. Prices are USD per 1M tokens.
 * Values reflect OpenAI's public list prices and are kept intentionally
 * conservative — unknown models return {@code null} rather than a guess.
 *
 * <p>Matching tries exact match first, then longest prefix match so that
 * dated variants like {@code gpt-4o-mini-2024-07-18} resolve to
 * {@code gpt-4o-mini}.</p>
 */
public final class OpenAiPricing {

    public record Pricing(BigDecimal inputUsdPer1M, BigDecimal outputUsdPer1M) {
    }

    private static final BigDecimal MILLION = new BigDecimal("1000000");

    // Keep ordering: longer prefixes first so iteration finds the most specific match.
    private static final Map<String, Pricing> TABLE = new LinkedHashMap<>();

    static {
        TABLE.put("gpt-4.1-nano", new Pricing(new BigDecimal("0.10"), new BigDecimal("0.40")));
        TABLE.put("gpt-4.1-mini", new Pricing(new BigDecimal("0.40"), new BigDecimal("1.60")));
        TABLE.put("gpt-4.1", new Pricing(new BigDecimal("2.00"), new BigDecimal("8.00")));
        TABLE.put("gpt-4o-mini", new Pricing(new BigDecimal("0.15"), new BigDecimal("0.60")));
        TABLE.put("gpt-4o", new Pricing(new BigDecimal("2.50"), new BigDecimal("10.00")));
        TABLE.put("gpt-4-turbo", new Pricing(new BigDecimal("10.00"), new BigDecimal("30.00")));
        TABLE.put("gpt-4", new Pricing(new BigDecimal("30.00"), new BigDecimal("60.00")));
        TABLE.put("gpt-3.5-turbo", new Pricing(new BigDecimal("0.50"), new BigDecimal("1.50")));
        TABLE.put("o1-mini", new Pricing(new BigDecimal("3.00"), new BigDecimal("12.00")));
        TABLE.put("o1", new Pricing(new BigDecimal("15.00"), new BigDecimal("60.00")));
        TABLE.put("o3-mini", new Pricing(new BigDecimal("1.10"), new BigDecimal("4.40")));
        TABLE.put("o3", new Pricing(new BigDecimal("10.00"), new BigDecimal("40.00")));
    }

    private OpenAiPricing() {
    }

    /**
     * Resolves pricing for the given model name. {@code null} / empty returns
     * {@code null}. Unknown models return {@code null} — callers must treat
     * that as "cost unknown".
     */
    public static Pricing lookup(String model) {
        if (model == null || model.isBlank()) {
            return null;
        }
        String key = model.trim().toLowerCase();
        Pricing exact = TABLE.get(key);
        if (exact != null) {
            return exact;
        }
        String bestPrefix = null;
        for (String candidate : TABLE.keySet()) {
            if (key.startsWith(candidate) && (bestPrefix == null || candidate.length() > bestPrefix.length())) {
                bestPrefix = candidate;
            }
        }
        return bestPrefix == null ? null : TABLE.get(bestPrefix);
    }

    /**
     * Estimated cost in USD for the given model and token counts. Returns
     * {@code null} when no pricing is known for the model.
     */
    public static BigDecimal estimate(String model, long promptTokens, long completionTokens) {
        Pricing pricing = lookup(model);
        if (pricing == null) {
            return null;
        }
        BigDecimal input = pricing.inputUsdPer1M()
                .multiply(BigDecimal.valueOf(Math.max(0, promptTokens)))
                .divide(MILLION, 6, RoundingMode.HALF_UP);
        BigDecimal output = pricing.outputUsdPer1M()
                .multiply(BigDecimal.valueOf(Math.max(0, completionTokens)))
                .divide(MILLION, 6, RoundingMode.HALF_UP);
        return input.add(output);
    }
}
