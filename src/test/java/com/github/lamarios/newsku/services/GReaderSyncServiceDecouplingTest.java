package com.github.lamarios.newsku.services;

import com.github.lamarios.newsku.models.OpenAiFeedResponse;
import com.github.lamarios.newsku.models.greader.GReaderStreamContents;
import com.github.lamarios.newsku.models.greader.GReaderStreamItem;
import com.github.lamarios.newsku.persistence.entities.Feed;
import com.github.lamarios.newsku.persistence.entities.FeedItem;
import com.github.lamarios.newsku.persistence.entities.User;
import com.github.lamarios.newsku.persistence.repositories.FeedCategoryRepository;
import com.github.lamarios.newsku.persistence.repositories.FeedErrorRepository;
import com.github.lamarios.newsku.persistence.repositories.FeedItemRepository;
import com.github.lamarios.newsku.persistence.repositories.FeedRepository;
import com.github.lamarios.newsku.persistence.repositories.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.InOrder;

import java.util.List;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.atLeastOnce;
import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * Unit-level guard for the persistence/AI decoupling fix in
 * {@link GReaderSyncService}. The synchronous path used to wait for OpenAI
 * before {@code saveAll}'ing the batch, so a slow AI backend made new items
 * invisible in the feed view for hours. This test pins the new contract:
 *
 * <ol>
 *   <li>Items are persisted before any AI call happens.</li>
 *   <li>AI enrichment runs after persistence and back-fills the rows.</li>
 *   <li>{@code syncAll()} is guarded against overlapping cron ticks.</li>
 * </ol>
 */
class GReaderSyncServiceDecouplingTest {

    private GReaderApiService greader;
    private UserRepository userRepository;
    private FeedRepository feedRepository;
    private FeedCategoryRepository feedCategoryRepository;
    private FeedItemRepository feedItemRepository;
    private FeedErrorRepository feedErrorRepository;
    private OpenaiService openai;
    private ClickService clickService;

    private GReaderSyncService service;

    @BeforeEach
    void setUp() {
        greader = mock(GReaderApiService.class);
        userRepository = mock(UserRepository.class);
        feedRepository = mock(FeedRepository.class);
        feedCategoryRepository = mock(FeedCategoryRepository.class);
        feedItemRepository = mock(FeedItemRepository.class);
        feedErrorRepository = mock(FeedErrorRepository.class);
        openai = mock(OpenaiService.class);
        clickService = mock(ClickService.class);

        service = new GReaderSyncService(
                greader,
                userRepository,
                feedRepository,
                feedCategoryRepository,
                feedItemRepository,
                feedErrorRepository,
                openai,
                clickService,
                mock(org.springframework.transaction.PlatformTransactionManager.class));

        when(clickService.tagClicks(anyLong(), anyLong(), any())).thenReturn(List.of());
    }

    private static User user() {
        User u = new User();
        u.setId("user-1");
        u.setUsername("alice");
        // isAiEnabled() defaults to true when enableAi is null — no setter needed.
        return u;
    }

    private static Feed feed(String streamId, User user) {
        Feed f = new Feed();
        f.setId("feed-1");
        f.setGReaderFeedId(streamId);
        f.setUser(user);
        f.setName("test feed");
        f.setUrl("https://example.com");
        return f;
    }

    private static GReaderStreamItem streamItem(String id, String streamId) {
        GReaderStreamItem it = new GReaderStreamItem();
        it.setId(id);
        it.setTitle("title-" + id);
        it.setPublished(System.currentTimeMillis() / 1000);
        GReaderStreamItem.Origin origin = new GReaderStreamItem.Origin();
        origin.setStreamId(streamId);
        it.setOrigin(origin);
        GReaderStreamItem.Content body = new GReaderStreamItem.Content();
        body.setContent("body-" + id);
        it.setSummary(body);
        return it;
    }

    private static GReaderStreamContents page(List<GReaderStreamItem> items) {
        GReaderStreamContents c = new GReaderStreamContents();
        c.setItems(items);
        c.setContinuation(null);
        return c;
    }

    @Test
    void syncArticles_persistsBatchAndThenInvokesEnrichment() {
        User user = user();
        Feed feed = feed("feed/test", user);

        when(greader.getUnreadItems(any(), any())).thenReturn(page(List.of(
                streamItem("a", "feed/test"),
                streamItem("b", "feed/test"))));
        when(feedItemRepository.findByGReaderItemId(anyString())).thenReturn(null);
        when(feedRepository.findByGReaderFeedIdAndUser(anyString(), any())).thenReturn(feed);
        when(feedItemRepository.findById(anyString())).thenReturn(Optional.empty());

        int total = service.syncArticles(user);

        assertEquals(2, total);
        // saveAll must be called before any per-item enrichment lookup.
        InOrder order = inOrder(feedItemRepository);
        order.verify(feedItemRepository).saveAll(anyList());
        order.verify(feedItemRepository, atLeastOnce()).findById(anyString());
        // No AI call ever resolves an item here (findById returns empty), so
        // openai must not be touched — proving the persistence path is fully
        // independent of the AI backend.
        verify(openai, never())
                .processFeedItem(anyString(), anyString(), anyString(), anyLong(), any(), anyList());
    }

    @Test
    void persistedItemsCarryNoAiFieldsBeforeEnrichment() {
        User user = user();
        Feed feed = feed("feed/test", user);

        when(greader.getUnreadItems(any(), any())).thenReturn(page(List.of(streamItem("a", "feed/test"))));
        when(feedItemRepository.findByGReaderItemId(anyString())).thenReturn(null);
        when(feedRepository.findByGReaderFeedIdAndUser(anyString(), any())).thenReturn(feed);
        when(feedItemRepository.findById(anyString())).thenReturn(Optional.empty());
        when(openai.processFeedItem(anyString(), anyString(), anyString(), anyLong(), any(), anyList()))
                .thenReturn(Optional.empty());

        service.syncArticles(user);

        @SuppressWarnings("unchecked")
        ArgumentCaptor<List<FeedItem>> captor = ArgumentCaptor.forClass(List.class);
        verify(feedItemRepository).saveAll(captor.capture());
        List<FeedItem> persisted = captor.getValue();
        assertEquals(1, persisted.size());
        FeedItem it = persisted.get(0);
        assertNull(it.getReasoning(), "reasoning must be null at persistence time");
        assertNull(it.getShortTitle(), "shortTitle must be null at persistence time");
        assertNull(it.getShortTeaser(), "shortTeaser must be null at persistence time");
        assertEquals(0, it.getImportance(), "importance must default to 0 (visible in feed)");
        assertNotNull(it.getTags());
        assertTrue(it.getTags().isEmpty());
    }

    @Test
    void asyncEnrichmentBackfillsAiFieldsOnPersistedItem() {
        User user = user();

        FeedItem persisted = new FeedItem();
        persisted.setId("item-1");
        persisted.setGReaderItemId("greader-1");
        persisted.setTitle("title");
        persisted.setDescription("body");
        persisted.setTimeCreated(System.currentTimeMillis());
        persisted.setTags(List.of());

        when(feedItemRepository.findById("item-1")).thenReturn(Optional.of(persisted));
        when(openai.processFeedItem(anyString(), anyString(), anyString(), anyLong(), any(), anyList()))
                .thenReturn(Optional.of(new OpenAiFeedResponse(
                        77, false, "because reasons",
                        List.of("Tech", "AI!"),
                        "Short title", "Short teaser sentence.")));

        service.enrichBatchAsync(List.of("item-1"), user);

        ArgumentCaptor<FeedItem> captor = ArgumentCaptor.forClass(FeedItem.class);
        verify(feedItemRepository).save(captor.capture());
        FeedItem updated = captor.getValue();
        assertEquals(77, updated.getImportance());
        assertEquals("because reasons", updated.getReasoning());
        assertEquals("Short title", updated.getShortTitle());
        assertEquals("Short teaser sentence.", updated.getShortTeaser());
        assertEquals(List.of("tech", "ai"), updated.getTags());
    }

    @Test
    void enrichmentSkipsAlreadyScoredItems() {
        User user = user();
        FeedItem alreadyScored = new FeedItem();
        alreadyScored.setId("item-2");
        alreadyScored.setReasoning("already scored");

        when(feedItemRepository.findById("item-2")).thenReturn(Optional.of(alreadyScored));

        service.enrichBatchAsync(List.of("item-2"), user);

        verify(openai, never()).processFeedItem(anyString(), anyString(), anyString(), anyLong(), any(), anyList());
        verify(feedItemRepository, never()).save(any(FeedItem.class));
    }

    @Test
    void syncAll_concurrentInvocationsAreSerialised() throws Exception {
        AtomicInteger inflight = new AtomicInteger();
        AtomicInteger overlaps = new AtomicInteger();

        when(userRepository.findAll()).thenAnswer(inv -> {
            int n = inflight.incrementAndGet();
            if (n > 1) overlaps.incrementAndGet();
            try {
                Thread.sleep(80);
            } finally {
                inflight.decrementAndGet();
            }
            return List.<User>of();
        });

        Thread t1 = new Thread(service::syncAll);
        Thread t2 = new Thread(service::syncAll);
        t1.start();
        // Give t1 a head start so the guard takes effect deterministically.
        Thread.sleep(20);
        t2.start();
        t1.join();
        t2.join();

        assertEquals(0, overlaps.get(), "syncAll runs must not overlap");
        // The second tick should have been skipped, so userRepository.findAll
        // is invoked exactly once.
        verify(userRepository, times(1)).findAll();
    }
}
