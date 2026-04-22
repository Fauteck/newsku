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

    /**
     * Sums successful-call token usage for the current-month limit check.
     * Error rows and rows with a NULL total_tokens (Ollama responses without a
     * usage field) are excluded — we only count tokens we actually know about.
     */
    @Query("""
            SELECT COALESCE(SUM(u.totalTokens), 0) FROM OpenaiUsage u
             WHERE u.user = :user
               AND u.useCase = :useCase
               AND u.status = com.github.lamarios.newsku.models.UsageStatus.OK
               AND u.createdAt >= :from
               AND u.createdAt < :to
            """)
    long sumTotalTokens(@Param("user") User user,
                        @Param("useCase") OpenAiUseCase useCase,
                        @Param("from") long from,
                        @Param("to") long to);

    /**
     * Returns only successful calls for aggregation/statistics — error rows do
     * not represent actual token usage.
     */
    @Query("""
            SELECT u FROM OpenaiUsage u
             WHERE u.user = :user
               AND u.status = com.github.lamarios.newsku.models.UsageStatus.OK
               AND u.createdAt >= :from
               AND u.createdAt < :to
            """)
    List<OpenaiUsage> findSuccessfulByUserAndCreatedAtBetween(@Param("user") User user,
                                                              @Param("from") long from,
                                                              @Param("to") long to);

    /** Log view returns every row — success and error — so the UI can show failures too. */
    Page<OpenaiUsage> findByUserOrderByCreatedAtDesc(User user, Pageable pageable);
}
