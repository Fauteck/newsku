package com.github.lamarios.newsku.controllers;

import com.github.lamarios.newsku.services.ResetPasswordService;
import freemarker.template.TemplateException;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;

@RestController
@Tag(name = "Reset password")
@RequestMapping("/reset-password")
public class ResetPasswordController {


    private final ResetPasswordService resetPasswordService;

    public ResetPasswordController(ResetPasswordService resetPasswordService) {
        this.resetPasswordService = resetPasswordService;
    }

    @PostMapping
    public void forgotPassword(@RequestBody String email) throws TemplateException, IOException {
        resetPasswordService.forgotPassword(email);
    }

    @PostMapping
    public void resetPassword(@RequestBody String password, @RequestParam("token") String token){
        resetPasswordService.resetPassword(token, password);
    }
}