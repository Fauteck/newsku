package com.github.lamarios.newsku.persistence.repositories;

import com.github.lamarios.newsku.persistence.entities.LayoutBlock;
import com.github.lamarios.newsku.persistence.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LayoutRepository extends JpaRepository<LayoutBlock, String> {
    List<LayoutBlock> findByUserOrderByOrder(User user);

    void deleteByUser(User user);
}
