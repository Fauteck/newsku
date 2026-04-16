package com.github.lamarios.newsku.persistence.repositories;

import com.github.lamarios.newsku.persistence.entities.AiPrompt;
import com.github.lamarios.newsku.persistence.entities.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AiPromptRepository extends JpaRepository<AiPrompt, String> {
    List<AiPrompt> findByUserOrderByName(User user);
}
