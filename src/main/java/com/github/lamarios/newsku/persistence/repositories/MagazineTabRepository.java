package com.github.lamarios.newsku.persistence.repositories;

import com.github.lamarios.newsku.persistence.entities.MagazineTab;
import com.github.lamarios.newsku.persistence.entities.User;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface MagazineTabRepository extends JpaRepository<MagazineTab, String> {
    List<MagazineTab> findByUserOrderByDisplayOrder(User user);

    @EntityGraph(attributePaths = "user")
    Optional<MagazineTab> findByIdAndIsPublicTrue(String id);
}
