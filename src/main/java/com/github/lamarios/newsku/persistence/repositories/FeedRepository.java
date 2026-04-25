package com.github.lamarios.newsku.persistence.repositories;


import com.github.lamarios.newsku.persistence.entities.Feed;
import com.github.lamarios.newsku.persistence.entities.User;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface FeedRepository extends JpaRepository<Feed, String> {
    @EntityGraph(attributePaths = {"category"})
    List<Feed> getFeedsByUser(User user);

    User user(User user);

    Feed getFirstById(String id);

    Feed findFirstByIdAndUser(String id, User user);


    List<Feed> findFirstByUrlAndUser(String url, User user);

    @Query("select sum(f.lastRefreshErrors) from Feed f where f.user = :user")
    Long sumFeedsError(@Param("user") User user);

    // Spring Data interprets the "GR" prefix as an acronym and would look up a
    // non-existent "GReaderFeedId" property, so the JPQL is written by hand.
    @Query("select f from Feed f where f.gReaderFeedId = :gReaderFeedId and f.user = :user")
    Feed findByGReaderFeedIdAndUser(@Param("gReaderFeedId") String gReaderFeedId, @Param("user") User user);
}
