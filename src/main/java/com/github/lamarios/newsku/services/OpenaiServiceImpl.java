package com.github.lamarios.newsku.services;

import com.apptasticsoftware.rssreader.Item;
import com.github.lamarios.newsku.models.OpenAiFeedResponse;
import com.github.lamarios.newsku.models.TagClickStat;
import com.github.lamarios.newsku.persistence.entities.User;
import com.openai.client.OpenAIClient;
import com.openai.client.okhttp.OpenAIOkHttpClient;
import com.openai.models.chat.completions.ChatCompletionCreateParams;
import com.openai.models.chat.completions.StructuredChatCompletionCreateParams;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service("openaiService")
public class OpenaiServiceImpl implements OpenaiService {

    private final static Logger logger = LogManager.getLogger();
    private final String url;
    private final String apiKey;
    private final String model;
    private final int maxRetries;
    private final long timeoutMinutes;

    @Autowired
    public OpenaiServiceImpl(
            @Value("${OPENAI_URL}") String url,
            @Value("${OPENAI_API_KEY:}") String apiKey,
            @Value("${OPENAI_MODEL}") String model,
            @Value("${OPENAI_MAX_RETRIES:3}") int maxRetries,
            @Value("${OPENAI_TIMEOUT_MINUTES:2}") long timeoutMinutes) {
        this.url = url;
        this.apiKey = apiKey;
        this.model = model;
        this.maxRetries = maxRetries;
        this.timeoutMinutes = timeoutMinutes;
        logger.info("OpenAI service initialized with model={}, url={}", model, url);
    }

    private OpenAIClient getClient() {
        var client = OpenAIOkHttpClient.builder().baseUrl(url)
                .checkJacksonVersionCompatibility(false);

        if (apiKey != null && !apiKey.trim().isBlank()) {
            client = client.apiKey(apiKey);
        }

        // Fix: reassign builder result so timeout is actually applied
        client = client.timeout(Duration.ofMinutes(timeoutMinutes));

        return client.build();
    }

    @Override
    public Optional<OpenAiFeedResponse> processFeedItem(Item item, User user, List<TagClickStat> clickStats) {
        String content = item.getDescription()
                .filter(s -> !s.isBlank())
                .orElseGet(() -> item.getContent().orElse("no content"));
        return processFeedItem(item.getGuid().orElse("unknown"), item.getTitle().orElse("no title"), content, user, clickStats);
    }

    @Override
    public Optional<OpenAiFeedResponse> processFeedItem(String guid, String title, String content, User user, List<TagClickStat> clickStats) {
        for (int attempt = 1; attempt <= maxRetries; attempt++) {
            try {
                return processFeedItemAttempt(guid, title, content, user, clickStats);
            } catch (Exception e) {
                if (attempt >= maxRetries) {
                    logger.error("OpenAI API call failed after {} attempts for item {}: {}",
                            maxRetries, guid, e.getMessage());
                    return Optional.empty();
                }
                long backoffMs = (1L << attempt) * 1000; // 2s, 4s, 8s …
                logger.warn("OpenAI API call failed (attempt {}/{}), retrying in {}ms: {}",
                        attempt, maxRetries, backoffMs, e.getMessage());
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

    private Optional<OpenAiFeedResponse> processFeedItemAttempt(String guid, String title, String content, User user, List<TagClickStat> clickStats) {

        String tagPrompt = """
                  These are the tags the user clicked on the most in the past 30 days ordered from the most clicked to the least clicked. Those tags may slightly affect your scoring:
                  %s
                """.formatted(clickStats.stream()
                .sorted((o1, o2) -> Long.compare(o2.clicks(), o1.clicks()))
                .limit(10)
                .map(s -> "%s (%d clicks)".formatted(s.tag(), s.clicks()))
                .collect(Collectors.joining(", ")));

        var start = System.currentTimeMillis();
        String prompt = """
                Your task is to identify is this news item is important or not
                you will rate the importance from 0 to a 100, 100 being the most important, be very granular in the rating
                Keep in mind that this is a ranking system for a RSS feed reader so the user might have 100s of news on a daily basis so do not be too eager on overrating news
                also you will try to figure out if this feed item is an ad or not

                You will use the name and description of the source to understand what an important news is for a user.
                You will also tag the article with up to 4 tags

                The user has the following preferences. You will refer to it to figure out how to rate a news item:
                %s

                %s

                Here is the news item:

                title: %s
                content: %s

                """.formatted(Optional.ofNullable(user.getFeedItemPreference())
                        .filter(s -> !s.isBlank())
                        .orElse("The user has no particular preferences"),
                clickStats.isEmpty() ? "" : tagPrompt,
                title,
                content);

        StructuredChatCompletionCreateParams<OpenAiFeedResponse> params = ChatCompletionCreateParams.builder()
                .addUserMessage(prompt)
                .model(model)
                .responseFormat(OpenAiFeedResponse.class)
                .build();

        List<OpenAiFeedResponse> analysis = getClient().chat().completions().create(params).choices().stream()
                .flatMap(choice -> choice.message().content().stream())
                .toList();

        Optional<OpenAiFeedResponse> first = analysis.stream().findFirst();
        first.ifPresent(r -> logger.info("Analysis results for feed item: {}:\nimportance: {}\npossible ad: {}\nreasoning: {}\ntags: {}\ntime: {}s",
                guid, r.importance(), r.possibleAd(), r.reasoning(), String.join(",", r.tags()), (System.currentTimeMillis() - start) / 1000));
        return first;
    }
}
