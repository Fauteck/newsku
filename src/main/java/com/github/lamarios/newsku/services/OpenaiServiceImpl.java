package com.github.lamarios.newsku.services;

import com.apptasticsoftware.rssreader.Item;
import com.github.lamarios.newsku.errors.OpenAiQuotaExceededException;
import com.github.lamarios.newsku.models.OpenAiFeedResponse;
import com.github.lamarios.newsku.models.OpenAiRelevanceResponse;
import com.github.lamarios.newsku.models.OpenAiShorteningResponse;
import com.github.lamarios.newsku.models.OpenAiUseCase;
import com.github.lamarios.newsku.models.TagClickStat;
import com.github.lamarios.newsku.persistence.entities.User;
import com.openai.client.OpenAIClient;
import com.openai.client.okhttp.OpenAIOkHttpClient;
import com.openai.models.chat.completions.ChatCompletionCreateParams;
import com.openai.models.chat.completions.StructuredChatCompletion;
import com.openai.models.chat.completions.StructuredChatCompletionCreateParams;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * OpenAI integration for per-article enrichment. Produces two independent
 * calls per article:
 *   1. Relevance scoring  → importance, possibleAd, tags, reasoning
 *   2. Text shortening   → shortTitle + shortTeaser
 *
 * The split lets us account tokens per use case and lets the user disable or
 * individually limit the shortening call (see {@link OpenaiUsageService}).
 *
 * Per-user config (API key, model, base URL) takes precedence over the
 * environment fallbacks.
 */
@Service("openaiService")
public class OpenaiServiceImpl implements OpenaiService {

    private static final Logger logger = LogManager.getLogger();

    private final String defaultUrl;
    private final String defaultApiKey;
    private final String defaultModel;
    private final int maxRetries;
    private final long timeoutMinutes;

    private final OpenaiUsageService usageService;

    @Autowired
    public OpenaiServiceImpl(
            @Value("${OPENAI_URL:https://api.openai.com/v1}") String url,
            @Value("${OPENAI_API_KEY:}") String apiKey,
            @Value("${OPENAI_MODEL:gpt-4o-mini}") String model,
            @Value("${OPENAI_MAX_RETRIES:3}") int maxRetries,
            @Value("${OPENAI_TIMEOUT_MINUTES:2}") long timeoutMinutes,
            OpenaiUsageService usageService) {
        this.defaultUrl = url;
        this.defaultApiKey = apiKey;
        this.defaultModel = model;
        this.maxRetries = maxRetries;
        this.timeoutMinutes = timeoutMinutes;
        this.usageService = usageService;
        logger.info("OpenAI service initialized (default model={}, default url={})", model, url);
    }

    // -----------------------------------------------------------------------
    // Public API
    // -----------------------------------------------------------------------

    @Override
    public Optional<OpenAiFeedResponse> processFeedItem(Item item, User user, List<TagClickStat> clickStats) {
        String content = item.getDescription()
                .filter(s -> !s.isBlank())
                .orElseGet(() -> item.getContent().orElse("no content"));
        long articleTimeMs = item.getPubDateAsZonedDateTime()
                .map(zdt -> zdt.toInstant().toEpochMilli())
                .orElse(System.currentTimeMillis());
        return processFeedItem(
                item.getGuid().orElse("unknown"),
                item.getTitle().orElse("no title"),
                content,
                articleTimeMs,
                user,
                clickStats);
    }

    @Override
    public Optional<OpenAiFeedResponse> processFeedItem(String guid, String title, String content, long articleTimeMs, User user, List<TagClickStat> clickStats) {
        if (!user.isAiEnabled()) {
            return Optional.empty();
        }
        if (!hasAiEndpoint(user)) {
            logger.debug("Skipping AI analysis for user {} – no API key or endpoint configured", user.getUsername());
            return Optional.empty();
        }
        // Fresh-install optimisation: skip AI for articles that predate the day the
        // user first configured their AI endpoint. This prevents bulk-scoring of all
        // historical articles on initial import and saves token quota.
        Long aiEnabledSince = user.getAiEnabledSince();
        if (aiEnabledSince != null && articleTimeMs < aiEnabledSince) {
            logger.debug("Skipping AI for article {} – published before AI activation ({})", guid, aiEnabledSince);
            return Optional.empty();
        }
        Optional<OpenAiRelevanceResponse> relevance = scoreRelevance(guid, title, content, user, clickStats);
        if (relevance.isEmpty()) {
            return Optional.empty();
        }

        Optional<OpenAiShorteningResponse> shortened = Optional.empty();
        if (shortenEnabled(user)) {
            shortened = shortenText(guid, title, content, user);
        }

        String shortTitle = shortened.map(OpenAiShorteningResponse::shortTitle).orElse(null);
        String shortTeaser = shortened.map(OpenAiShorteningResponse::shortTeaser).orElse(null);

        OpenAiRelevanceResponse r = relevance.get();
        return Optional.of(new OpenAiFeedResponse(
                r.importance(),
                r.possibleAd(),
                r.reasoning(),
                r.tags() != null ? r.tags() : Collections.emptyList(),
                shortTitle,
                shortTeaser));
    }

    // -----------------------------------------------------------------------
    // Relevance scoring
    // -----------------------------------------------------------------------

    private Optional<OpenAiRelevanceResponse> scoreRelevance(String guid, String title, String content,
                                                             User user, List<TagClickStat> clickStats) {
        if (usageService.isLimitExceeded(user, OpenAiUseCase.RELEVANCE)) {
            logger.warn("OpenAI RELEVANCE monthly token limit reached for user {} — skipping article {}",
                    user.getUsername(), guid);
            return Optional.empty();
        }

        String tagPrompt = clickStats.isEmpty() ? "" : """
                These are the tags the user clicked on the most in the past 30 days ordered from the most clicked to the least clicked. Those tags may slightly affect your scoring:
                %s
                """.formatted(clickStats.stream()
                .sorted((a, b) -> Long.compare(b.clicks(), a.clicks()))
                .limit(10)
                .map(s -> "%s (%d clicks)".formatted(s.tag(), s.clicks()))
                .collect(Collectors.joining(", ")));

        String prompt = """
                Your task is to identify if this news item is important or not.
                You will rate the importance from 0 to 100, 100 being the most important, be very granular in the rating.
                Keep in mind that this is a ranking system for a RSS feed reader so the user might have 100s of news on a daily basis so do not be too eager on overrating news.
                Also you will try to figure out if this feed item is an ad or not.

                You will use the name and description of the source to understand what an important news is for a user.
                You will also tag the article with up to 4 tags.

                The user has the following preferences. You will refer to it to figure out how to rate a news item:
                %s

                %s

                Here is the news item:

                title: %s
                content: %s
                """.formatted(
                Optional.ofNullable(user.getFeedItemPreference())
                        .filter(s -> !s.isBlank())
                        .orElse("The user has no particular preferences"),
                tagPrompt,
                title,
                content);

        return callWithRetry(user, OpenAiUseCase.RELEVANCE, guid, prompt, OpenAiRelevanceResponse.class);
    }

    // -----------------------------------------------------------------------
    // Text shortening
    // -----------------------------------------------------------------------

    private Optional<OpenAiShorteningResponse> shortenText(String guid, String title, String content, User user) {
        if (usageService.isLimitExceeded(user, OpenAiUseCase.SHORTENING)) {
            logger.warn("OpenAI SHORTENING monthly token limit reached for user {} — skipping article {}",
                    user.getUsername(), guid);
            return Optional.empty();
        }

        String prompt = """
                Produce two shortened rewrites of the following news item tailored for
                compact card layouts. These are full, self-contained sentences/phrases —
                NOT truncations with ellipses. Keep the article's original language.

                  - shortTitle: a concise headline variant, max ~60 characters, fitting
                    on two lines in a grid card. Keep it factual and descriptive.
                  - shortTeaser: a one-sentence teaser of the article, max ~140
                    characters. It must end as a complete sentence.

                If the article is too short to sensibly shorten further, copy the
                original text.

                title: %s
                content: %s
                """.formatted(title, content);

        return callWithRetry(user, OpenAiUseCase.SHORTENING, guid, prompt, OpenAiShorteningResponse.class);
    }

    // -----------------------------------------------------------------------
    // Shared call/retry/track plumbing
    // -----------------------------------------------------------------------

    private <T> Optional<T> callWithRetry(User user, OpenAiUseCase useCase, String guid,
                                          String prompt, Class<T> responseClass) {
        String model = effectiveModel(user);
        OpenAIClient client;
        try {
            client = buildClient(user);
        } catch (IllegalStateException e) {
            logger.debug("OpenAI client unavailable for user {} ({}): {}",
                    user.getUsername(), useCase, e.getMessage());
            return Optional.empty();
        }

        for (int attempt = 1; attempt <= maxRetries; attempt++) {
            try {
                return singleCall(client, model, user, useCase, guid, prompt, responseClass);
            } catch (Exception e) {
                if (isQuotaOrRateLimit(e)) {
                    logger.error("OpenAI {} quota exceeded for user {} — aborting sync: {}",
                            useCase, user.getUsername(), e.getMessage());
                    throw new OpenAiQuotaExceededException(
                            "OpenAI quota/rate limit hit for user " + user.getUsername() + ": " + e.getMessage());
                }
                if (attempt >= maxRetries) {
                    logger.error("OpenAI {} call failed after {} attempts for item {}: {}",
                            useCase, maxRetries, guid, e.getMessage());
                    return Optional.empty();
                }
                long backoffMs = (1L << attempt) * 1000L;
                logger.warn("OpenAI {} call failed (attempt {}/{}), retrying in {}ms: {}",
                        useCase, attempt, maxRetries, backoffMs, e.getMessage());
                try {
                    Thread.sleep(backoffMs);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    return Optional.empty();
                }
            }
        }
        return Optional.empty();
    }

    /**
     * Detects whether an OpenAI SDK exception represents a 429 quota/rate-limit
     * response. Checks the exception class name (to tolerate SDK version skew
     * without a hard compile-time dependency) and falls back to the message
     * body, since the SDK's {@code toString()} format ({@code "429: ..."}) is
     * what we actually observe in logs.
     */
    static boolean isQuotaOrRateLimit(Throwable e) {
        for (Throwable t = e; t != null; t = t.getCause()) {
            String cn = t.getClass().getName();
            if (cn.equals("com.openai.errors.RateLimitException")) return true;
            String msg = t.getMessage();
            if (msg == null) continue;
            String m = msg.toLowerCase();
            if (m.startsWith("429")
                    || m.contains("insufficient_quota")
                    || m.contains("exceeded your current quota")) {
                return true;
            }
        }
        return false;
    }

    private <T> Optional<T> singleCall(OpenAIClient client, String model, User user,
                                       OpenAiUseCase useCase, String guid,
                                       String prompt, Class<T> responseClass) {
        long start = System.currentTimeMillis();

        StructuredChatCompletionCreateParams<T> params = ChatCompletionCreateParams.builder()
                .addUserMessage(prompt)
                .model(model)
                .responseFormat(responseClass)
                .build();

        StructuredChatCompletion<T> completion = client.chat().completions().create(params);

        List<T> analysis = completion.choices().stream()
                .flatMap(choice -> choice.message().content().stream())
                .toList();

        recordUsage(user, useCase, model, completion);

        Optional<T> first = analysis.stream().findFirst();
        first.ifPresent(r -> logger.info("OpenAI {} result for {} took {}s",
                useCase, guid, (System.currentTimeMillis() - start) / 1000));
        return first;
    }

    private void recordUsage(User user, OpenAiUseCase useCase, String model, StructuredChatCompletion<?> completion) {
        try {
            completion.usage().ifPresent(u -> {
                long prompt = u.promptTokens();
                long comp = u.completionTokens();
                long total = u.totalTokens();
                usageService.record(user, useCase, model,
                        (int) Math.min(prompt, Integer.MAX_VALUE),
                        (int) Math.min(comp, Integer.MAX_VALUE),
                        (int) Math.min(total, Integer.MAX_VALUE),
                        null);
            });
        } catch (Exception e) {
            logger.debug("Could not extract OpenAI usage (SDK incompatibility?): {}", e.getMessage());
        }
    }

    // -----------------------------------------------------------------------
    // Per-user configuration helpers
    // -----------------------------------------------------------------------

    private OpenAIClient buildClient(User user) {
        String url = first(user.getOpenAiUrl(), defaultUrl);
        String apiKey = first(user.getOpenAiApiKey(), defaultApiKey);

        // Ollama and other self-hosted OpenAI-compatible servers don't require an API
        // key. The Java SDK still needs a non-empty value for the Authorization header;
        // the server ignores it. Use "ollama" as a harmless placeholder.
        if (apiKey == null || apiKey.isBlank()) {
            apiKey = "ollama";
        }

        var builder = OpenAIOkHttpClient.builder()
                .baseUrl(url)
                .apiKey(apiKey)
                .checkJacksonVersionCompatibility(false)
                .timeout(Duration.ofMinutes(timeoutMinutes));

        return builder.build();
    }

    private String effectiveModel(User user) {
        return first(user.getOpenAiModel(), defaultModel);
    }

    private boolean shortenEnabled(User user) {
        Boolean flag = user.getEnableTextShortening();
        // Default: enabled (backwards compatible with prior behaviour).
        return flag == null || flag;
    }

    /**
     * Returns true when the user has a usable AI endpoint configured: either an
     * explicit API key (required for OpenAI / Azure) or a custom URL pointing to a
     * self-hosted server such as Ollama that does not need a key.
     */
    private boolean hasAiEndpoint(User user) {
        String apiKey = first(user.getOpenAiApiKey(), defaultApiKey);
        if (apiKey != null && !apiKey.isBlank()) return true;
        // Custom URL without an API key → assume Ollama / compatible endpoint
        String url = user.getOpenAiUrl();
        return url != null && !url.isBlank();
    }

    private static String first(String primary, String fallback) {
        if (primary != null && !primary.isBlank()) return primary;
        return fallback;
    }
}
