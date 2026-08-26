package com.github.lamarios.newsku.services;

import com.github.lamarios.newsku.persistence.entities.Feed;
import com.github.lamarios.newsku.persistence.entities.FeedCategory;
import com.github.lamarios.newsku.persistence.entities.User;
import com.github.lamarios.newsku.persistence.repositories.FeedCategoryRepository;
import com.github.lamarios.newsku.persistence.repositories.FeedRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.concurrent.ConcurrentMapCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.context.junit.jupiter.SpringJUnitConfig;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.reset;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * Guards the SpEL cache keys of the two zero-argument, user-scoped caches
 * ("feedsByUser", "feedCategoriesByUser").
 *
 * <p>Both keys used to read the username straight out of the
 * {@code SecurityContextHolder}. That is a second source of truth next to
 * {@link UserService#getCurrentUser()}, and it fails hard —
 * {@code SpelEvaluationException EL1007E: Property or field 'name' cannot be
 * found on null} — for every caller that resolves its user some other way.
 * The whole JUnit suite does exactly that, which is how the caches took six
 * controller tests down at once.
 *
 * <p>This test needs no database and no Docker, so the regression is caught
 * even when the TestContainers-backed tests cannot start.
 */
@SpringJUnitConfig(UserScopedCacheKeyTest.CachingTestConfig.class)
public class UserScopedCacheKeyTest {

    @Configuration
    @EnableCaching
    static class CachingTestConfig {

        @Bean
        public CacheManager cacheManager() {
            return new ConcurrentMapCacheManager("feedsByUser", "feedCategoriesByUser");
        }

        @Bean
        public UserService userService() {
            return mock(UserService.class);
        }

        @Bean
        public FeedRepository feedRepository() {
            return mock(FeedRepository.class);
        }

        @Bean
        public FeedCategoryRepository feedCategoryRepository() {
            return mock(FeedCategoryRepository.class);
        }

        @Bean
        public FeedService feedService(UserService userService, FeedRepository feedRepository) {
            return new FeedService(userService, feedRepository);
        }

        @Bean
        public FeedCategoriesService feedCategoriesService(UserService userService,
                                                          FeedCategoryRepository feedCategoryRepository) {
            return new FeedCategoriesService(userService, feedCategoryRepository);
        }
    }

    @Autowired
    private FeedService feedService;

    @Autowired
    private FeedCategoriesService feedCategoriesService;

    @Autowired
    private UserService userService;

    @Autowired
    private FeedRepository feedRepository;

    @Autowired
    private FeedCategoryRepository feedCategoryRepository;

    @Autowired
    private CacheManager cacheManager;

    private final User alice = user("alice");
    private final User bob = user("bob");

    private static User user(String username) {
        User user = new User();
        user.setId(username);
        user.setUsername(username);
        return user;
    }

    private static Feed feed(String id) {
        Feed feed = new Feed();
        feed.setId(id);
        return feed;
    }

    private static FeedCategory category(String id) {
        FeedCategory category = new FeedCategory();
        category.setId(id);
        return category;
    }

    @BeforeEach
    public void resetState() {
        // No authenticated principal anywhere — the point of the test.
        SecurityContextHolder.clearContext();
        // The Spring context (and with it the mocks) is shared across methods.
        reset(userService, feedRepository, feedCategoryRepository);
        cacheManager.getCacheNames().forEach(name -> cacheManager.getCache(name).clear());
    }

    @Test
    public void getFeeds_worksWithoutASecurityContext_andCachesPerUser() {
        when(userService.getCurrentUser()).thenReturn(alice);
        when(feedRepository.getFeedsByUser(alice)).thenReturn(List.of(feed("alice-feed")));
        when(feedRepository.getFeedsByUser(bob)).thenReturn(List.of(feed("bob-feed")));

        assertEquals("alice-feed", feedService.getFeeds().getFirst().getId());
        // Second call for the same user is served from the cache.
        assertEquals("alice-feed", feedService.getFeeds().getFirst().getId());
        verify(feedRepository, times(1)).getFeedsByUser(alice);

        // A different user must not see the first user's cached list.
        when(userService.getCurrentUser()).thenReturn(bob);
        assertEquals("bob-feed", feedService.getFeeds().getFirst().getId());
        verify(feedRepository, times(1)).getFeedsByUser(bob);
    }

    @Test
    public void getCategories_worksWithoutASecurityContext_andCachesPerUser() {
        when(userService.getCurrentUser()).thenReturn(alice);
        when(feedCategoryRepository.getAllByUser(eq(alice), any(Sort.class)))
                .thenReturn(List.of(category("alice-category")));
        when(feedCategoryRepository.getAllByUser(eq(bob), any(Sort.class)))
                .thenReturn(List.of(category("bob-category")));

        assertEquals("alice-category", feedCategoriesService.getCategories().getFirst().getId());
        assertEquals("alice-category", feedCategoriesService.getCategories().getFirst().getId());
        verify(feedCategoryRepository, times(1)).getAllByUser(eq(alice), any(Sort.class));

        when(userService.getCurrentUser()).thenReturn(bob);
        assertEquals("bob-category", feedCategoriesService.getCategories().getFirst().getId());
        verify(feedCategoryRepository, times(1)).getAllByUser(eq(bob), any(Sort.class));
    }
}
