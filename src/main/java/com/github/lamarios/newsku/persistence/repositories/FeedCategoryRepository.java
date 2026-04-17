package com.github.lamarios.newsku.persistence.repositories;

import com.github.lamarios.newsku.persistence.entities.FeedCategory;
import com.github.lamarios.newsku.persistence.entities.User;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface FeedCategoryRepository extends JpaRepository<FeedCategory, String> {
    FeedCategory getFeedCategoriesByIdAndUser(String id, User user);

    List<FeedCategory> getAllByUser(User user, Sort sort);

    // Spring Data interprets the "GR" prefix as an acronym and would look up a
    // non-existent "GReaderCategoryId" property, so the JPQL is written by hand.
    @Query("select c from FeedCategory c where c.gReaderCategoryId = :gReaderCategoryId and c.user = :user")
    FeedCategory findByGReaderCategoryIdAndUser(@Param("gReaderCategoryId") String gReaderCategoryId, @Param("user") User user);
}
