package com.github.lamarios.newsku.persistence.repositories;

import com.github.lamarios.newsku.persistence.entities.LayoutBlock;
import com.github.lamarios.newsku.persistence.entities.MagazineTab;
import com.github.lamarios.newsku.persistence.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LayoutRepository extends JpaRepository<LayoutBlock, String> {
    List<LayoutBlock> findByUserAndTabIsNullOrderByOrder(User user);

    List<LayoutBlock> findByUserAndTabOrderByOrder(User user, MagazineTab tab);

    void deleteByUserAndTabIsNull(User user);

    void deleteByUserAndTab(User user, MagazineTab tab);

    /** @deprecated Use findByUserAndTabIsNullOrderByOrder */
    @Deprecated
    default List<LayoutBlock> findByUserOrderByOrder(User user) {
        return findByUserAndTabIsNullOrderByOrder(user);
    }

    /** @deprecated Use deleteByUserAndTabIsNull */
    @Deprecated
    default void deleteByUser(User user) {
        deleteByUserAndTabIsNull(user);
    }
}
