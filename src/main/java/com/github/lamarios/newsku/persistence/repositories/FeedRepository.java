package com.github.lamarios.newsku.persistence.repositories;


import com.github.lamarios.newsku.persistence.entities.Feed;
import com.github.lamarios.newsku.persistence.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface FeedRepository extends JpaRepository<Feed, UUID> {
    List<Feed> getFeedsByUser(User user);

    User user(User user);

    Feed getFirstById(String id);

}
