package com.github.lamarios.newsku.services;

import com.github.lamarios.newsku.errors.NewskuUserException;
import com.github.lamarios.newsku.persistence.entities.AiPrompt;
import com.github.lamarios.newsku.persistence.repositories.AiPromptRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class AiPromptService {

    private final AiPromptRepository aiPromptRepository;
    private final UserService userService;

    @Autowired
    public AiPromptService(AiPromptRepository aiPromptRepository, UserService userService) {
        this.aiPromptRepository = aiPromptRepository;
        this.userService = userService;
    }

    @Transactional(readOnly = true)
    public List<AiPrompt> getPrompts() {
        return aiPromptRepository.findByUserOrderByName(userService.getCurrentUser());
    }

    @Transactional
    public AiPrompt createPrompt(AiPrompt prompt) {
        prompt.setId(UUID.randomUUID().toString());
        prompt.setUser(userService.getCurrentUser());
        return aiPromptRepository.save(prompt);
    }

    @Transactional
    public AiPrompt updatePrompt(String id, AiPrompt updated) {
        var user = userService.getCurrentUser();
        var existing = aiPromptRepository.findById(id)
                .filter(p -> p.getUser().getId().equals(user.getId()))
                .orElseThrow(() -> new NewskuUserException("Prompt not found"));
        existing.setName(updated.getName());
        existing.setContent(updated.getContent());
        return aiPromptRepository.save(existing);
    }

    @Transactional
    public void deletePrompt(String id) {
        var user = userService.getCurrentUser();
        var prompt = aiPromptRepository.findById(id)
                .filter(p -> p.getUser().getId().equals(user.getId()))
                .orElseThrow(() -> new NewskuUserException("Prompt not found"));
        aiPromptRepository.delete(prompt);
    }
}
