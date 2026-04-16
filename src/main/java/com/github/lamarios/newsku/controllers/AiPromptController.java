package com.github.lamarios.newsku.controllers;

import com.github.lamarios.newsku.persistence.entities.AiPrompt;
import com.github.lamarios.newsku.services.AiPromptService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/ai/prompts")
@Tag(name = "AI")
@SecurityRequirement(name = "bearerAuth")
public class AiPromptController {

    private final AiPromptService aiPromptService;

    @Autowired
    public AiPromptController(AiPromptService aiPromptService) {
        this.aiPromptService = aiPromptService;
    }

    @GetMapping
    public List<AiPrompt> getPrompts() {
        return aiPromptService.getPrompts();
    }

    @PostMapping
    public AiPrompt createPrompt(@RequestBody AiPrompt prompt) {
        return aiPromptService.createPrompt(prompt);
    }

    @PutMapping("/{id}")
    public AiPrompt updatePrompt(@PathVariable String id, @RequestBody AiPrompt prompt) {
        return aiPromptService.updatePrompt(id, prompt);
    }

    @DeleteMapping("/{id}")
    public void deletePrompt(@PathVariable String id) {
        aiPromptService.deletePrompt(id);
    }
}
