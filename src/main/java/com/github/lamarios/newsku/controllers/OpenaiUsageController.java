package com.github.lamarios.newsku.controllers;

import com.github.lamarios.newsku.models.OpenAiUsageStats;
import com.github.lamarios.newsku.models.OpenAiUseCase;
import com.github.lamarios.newsku.services.OpenaiUsageService;
import com.github.lamarios.newsku.services.UserService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/openai/usage")
@Tag(name = "OpenAI Usage")
@SecurityRequirement(name = "bearerAuth")
public class OpenaiUsageController {

    private final OpenaiUsageService usageService;
    private final UserService userService;

    @Autowired
    public OpenaiUsageController(OpenaiUsageService usageService, UserService userService) {
        this.usageService = usageService;
        this.userService = userService;
    }

    /**
     * Returns per-use-case token usage for the current user.
     *
     * @param from inclusive start of window in ms since epoch; defaults to start of current month (UTC)
     * @param to   exclusive end of window in ms since epoch; defaults to "now"
     */
    @GetMapping
    public Map<OpenAiUseCase, OpenAiUsageStats> getUsage(
            @RequestParam(value = "from", required = false) Long from,
            @RequestParam(value = "to", required = false) Long to) {
        var user = userService.getCurrentUser();
        if (from == null || to == null) {
            return usageService.getMonthlyUsage(user);
        }
        return usageService.getUsage(user, from, to);
    }
}
