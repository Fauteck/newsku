package com.github.lamarios.newsku.persistence.repositories;

import com.github.lamarios.newsku.persistence.entities.Feed;
import com.github.lamarios.newsku.persistence.entities.FeedClick;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;

public interface FeedClicksRepository extends JpaRepository<FeedClick, String> {
    List<FeedClick> getAllByFeedInAndTimeCreatedBetween(Collection<Feed> feeds, long timeCreatedAfter, long timeCreatedBefore);
}
