package com.github.lamarios.newsku.persistence.repositories;

import com.github.lamarios.newsku.persistence.entities.TagClick;
import com.github.lamarios.newsku.persistence.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TagClicksRepository extends JpaRepository<TagClick, String> {
    List<TagClick> findTagClickByUserAndTimeCreatedBetween(User user, long timeCreatedAfter, long timeCreatedBefore);
}
