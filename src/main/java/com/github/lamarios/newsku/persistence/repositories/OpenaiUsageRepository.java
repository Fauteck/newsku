package com.github.lamarios.newsku.persistence.repositories;

import com.github.lamarios.newsku.models.OpenAiUseCase;
import com.github.lamarios.newsku.persistence.entities.OpenaiUsage;
import com.github.lamarios.newsku.persistence.entities.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface OpenaiUsageRepository extends JpaRepository<OpenaiUsage, String> {

    @Query("""
            SELECT COALESCE(SUM(u.totalTokens), 0) FROM OpenaiUsage u
             WHERE u.user = :user
               AND u.useCase = :useCase
               AND u.createdAt >= :from
               AND u.createdAt < :to
            """)
    long sumTotalTokens(@Param("user") User user,
                        @Param("useCase") OpenAiUseCase useCase,
                        @Param("from") long from,
                        @Param("to") long to);

    List<OpenaiUsage> findByUserAndCreatedAtBetween(User user, long from, long to);

    Page<OpenaiUsage> findByUserOrderByCreatedAtDesc(User user, Pageable pageable);
}
