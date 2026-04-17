package com.github.lamarios.newsku.services;

import com.github.lamarios.newsku.TestConfig;
import com.github.lamarios.newsku.TestContainerTest;
import com.github.lamarios.newsku.models.OpenAiModelUsage;
import com.github.lamarios.newsku.models.OpenAiUsageStats;
import com.github.lamarios.newsku.models.OpenAiUseCase;
import com.github.lamarios.newsku.persistence.entities.User;
import com.github.lamarios.newsku.persistence.repositories.OpenaiUsageRepository;
import com.github.lamarios.newsku.persistence.repositories.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;

import java.math.BigDecimal;
import java.util.List;
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

    @Test
    void estimatesCostFromPricingTableWhenNotStored() {
        User user = userRepository.getUserByUsername("test").getFirst();

        // 1M input tokens on gpt-4o-mini → $0.15, 1M output → $0.60, sum $0.75
        usageService.record(user, OpenAiUseCase.RELEVANCE, "gpt-4o-mini",
                1_000_000, 1_000_000, 2_000_000, null);

        OpenAiUsageStats stats = usageService.getMonthlyUsage(user).get(OpenAiUseCase.RELEVANCE);
        assertNotNull(stats.estimatedCostUsd(), "pricing table must produce a cost");
        assertEquals(0, new BigDecimal("0.75").compareTo(stats.estimatedCostUsd()),
                "expected 0.75 USD, got " + stats.estimatedCostUsd());
    }

    @Test
    void unknownModelLeavesCostNull() {
        User user = userRepository.getUserByUsername("test").getFirst();
        usageService.record(user, OpenAiUseCase.SHORTENING, "some-other-model",
                100, 50, 150, null);

        OpenAiUsageStats stats = usageService.getMonthlyUsage(user).get(OpenAiUseCase.SHORTENING);
        assertEquals(150, stats.totalTokens());
        assertNull(stats.estimatedCostUsd(), "unknown model → no cost");
    }

    @Test
    void modelBreakdownGroupsPerModel() {
        User user = userRepository.getUserByUsername("test").getFirst();
        usageService.record(user, OpenAiUseCase.RELEVANCE, "gpt-4o-mini", 100, 50, 150, null);
        usageService.record(user, OpenAiUseCase.RELEVANCE, "gpt-4o-mini", 200, 100, 300, null);
        usageService.record(user, OpenAiUseCase.RELEVANCE, "gpt-4o", 10, 5, 15, null);

        OpenAiUsageStats stats = usageService.getMonthlyUsage(user).get(OpenAiUseCase.RELEVANCE);
        List<OpenAiModelUsage> breakdown = stats.modelBreakdown();
        assertEquals(2, breakdown.size());
        // sorted by totalTokens desc → gpt-4o-mini (450) first, gpt-4o (15) last
        assertEquals("gpt-4o-mini", breakdown.get(0).model());
        assertEquals(450, breakdown.get(0).totalTokens());
        assertEquals(2, breakdown.get(0).callCount());
        assertEquals("gpt-4o", breakdown.get(1).model());
        assertEquals(15, breakdown.get(1).totalTokens());
    }
}
