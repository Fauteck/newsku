package com.github.lamarios.newsku.persistence.repositories;

import com.github.lamarios.newsku.persistence.entities.Feed;
import com.github.lamarios.newsku.persistence.entities.FeedItem;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;

public interface FeedItemRepository extends JpaRepository<FeedItem, String> {
    FeedItem getFirstByGuid(String guid);


    @Query("select i from FeedItem i where i.feed in :feeds and i.importance >= :minImportance and i.timeCreated > :from and i.timeCreated <= :to")
    Page<FeedItem> findallByTimeAndFeeds(@Param("minImportance") int minImportance, @Param("from") long from, @Param("to") long to, @Param("feeds") List<Feed> feeds, Pageable pageable);

    List<FeedItem> findFirstByIdAndFeedIn(String id, Collection<Feed> feeds);

    List<FeedItem> findByIdInAndFeedIn(Collection<String> ids, Collection<Feed> feeds);

    FeedItem getFirstByGuidAndFeed(String guid, Feed feed);

    FeedItem getFirstByIdAndFeedIn(String id, Collection<Feed> feeds);

    List<FeedItem> findBySavedTrueAndFeedIn(Collection<Feed> feeds);

    // Spring Data interprets the "GR" prefix as an acronym and would look up a
    // non-existent "GReaderItemId" property, so the JPQL is written by hand.
    @Query("select i from FeedItem i where i.gReaderItemId = :gReaderItemId")
    FeedItem findByGReaderItemId(@Param("gReaderItemId") String gReaderItemId);

    @Query("select i from FeedItem i where i.gReaderItemId in :gReaderItemIds and i.feed in :feeds")
    List<FeedItem> findByGReaderItemIdInAndFeedIn(@Param("gReaderItemIds") Collection<String> gReaderItemIds, @Param("feeds") Collection<Feed> feeds);
}
