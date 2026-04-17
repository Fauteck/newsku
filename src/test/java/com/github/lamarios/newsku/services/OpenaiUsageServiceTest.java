package com.github.lamarios.newsku.services;

import com.github.lamarios.newsku.TestConfig;
import com.github.lamarios.newsku.TestContainerTest;
import com.github.lamarios.newsku.models.OpenAiUsageStats;
import com.github.lamarios.newsku.models.OpenAiUseCase;
import com.github.lamarios.newsku.persistence.entities.User;
import com.github.lamarios.newsku.persistence.repositories.OpenaiUsageRepository;
import com.github.lamarios.newsku.persistence.repositories.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

@Import(TestConfig.class)
public class OpenaiUsageServiceTest extends TestContainerTest {

    private final OpenaiUsageService usageService;
    private final OpenaiUsageRepository usageRepository;
    private final UserRepository userRepository;

    @Autowired
    public OpenaiUsageServiceTest(OpenaiUsageService usageService,
                                  OpenaiUsageRepository usageRepository,
                                  UserRepository userRepository) {
        this.usageService = usageService;
        this.usageRepository = usageRepository;
        this.userRepository = userRepository;
    }

    @Test
    void recordsAndAggregatesPerUseCase() {
        User user = userRepository.getUserByUsername("test").getFirst();

        usageService.record(user, OpenAiUseCase.RELEVANCE, "gpt-4o-mini", 100, 30, 130, null);
        usageService.record(user, OpenAiUseCase.RELEVANCE, "gpt-4o-mini", 50, 20, 70, null);
        usageService.record(user, OpenAiUseCase.SHORTENING, "gpt-4o-mini", 80, 40, 120, null);

        Map<OpenAiUseCase, OpenAiUsageStats> stats = usageService.getMonthlyUsage(user);

        assertEquals(200, stats.get(OpenAiUseCase.RELEVANCE).totalTokens());
        assertEquals(2, stats.get(OpenAiUseCase.RELEVANCE).callCount());
        assertEquals(120, stats.get(OpenAiUseCase.SHORTENING).totalTokens());
        assertEquals(1, stats.get(OpenAiUseCase.SHORTENING).callCount());
    }

    @Test
    void emptyWindowReturnsZeroesForEveryUseCase() {
        User user = userRepository.getUserByUsername("test").getFirst();
        Map<OpenAiUseCase, OpenAiUsageStats> stats = usageService.getMonthlyUsage(user);
        assertEquals(0, stats.get(OpenAiUseCase.RELEVANCE).totalTokens());
        assertEquals(0, stats.get(OpenAiUseCase.SHORTENING).totalTokens());
        assertNotNull(stats.get(OpenAiUseCase.RELEVANCE));
        assertNotNull(stats.get(OpenAiUseCase.SHORTENING));
    }

    @Test
    void limitIsExceededWhenMonthlySumMeetsOrPasses() {
        User user = userRepository.getUserByUsername("test").getFirst();
        user.setOpenAiMonthlyTokenLimitRelevance(100);
        userRepository.save(user);

        assertFalse(usageService.isLimitExceeded(user, OpenAiUseCase.RELEVANCE),
                "with zero usage and a 100 limit we are not exceeding");

        usageService.record(user, OpenAiUseCase.RELEVANCE, "m", 50, 20, 70, null);
        assertFalse(usageService.isLimitExceeded(user, OpenAiUseCase.RELEVANCE));

        usageService.record(user, OpenAiUseCase.RELEVANCE, "m", 20, 10, 30, null);
        assertTrue(usageService.isLimitExceeded(user, OpenAiUseCase.RELEVANCE),
                "70 + 30 = 100 ≥ limit — must be flagged exceeded");
    }

    @Test
    void unsetLimitIsNeverExceeded() {
        User user = userRepository.getUserByUsername("test").getFirst();
        usageService.record(user, OpenAiUseCase.SHORTENING, "m", 1_000_000, 1_000_000, 2_000_000, null);
        assertFalse(usageService.isLimitExceeded(user, OpenAiUseCase.SHORTENING),
                "no limit configured → never blocked");
    }
}
