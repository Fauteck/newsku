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


    @Query("select i from FeedItem i where i.timeCreated > :from and i.timeCreated <= :to and i.feed in :feeds")
    Page<FeedItem> findallByTimeAndFeeds(@Param("from") long from, @Param("to") long to, @Param("feeds") List<Feed> feeds, Pageable pageable);

    List<FeedItem> findFirstByIdAndFeedIn(String id, Collection<Feed> feeds);
}
