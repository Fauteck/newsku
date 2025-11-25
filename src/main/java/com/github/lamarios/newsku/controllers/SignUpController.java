package com.github.lamarios.newsku.controllers;

import com.github.lamarios.newsku.persistence.entities.User;
import com.github.lamarios.newsku.services.UserService;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/signup")
@Tag(name = "Log in")
public class SignUpController {
    private final UserService userService;
    private final boolean allowSignUp;

    @Autowired
    public SignUpController(UserService userService, @Value("${ALLOW_SIGNUP:0}") boolean allowSignUp) {
        this.userService = userService;
        this.allowSignUp = allowSignUp;
    }

    @PutMapping
    public User signup(@RequestBody  User user) {
        if (allowSignUp) {
            return userService.createUser(user);
        } else {
            throw new AccessDeniedException("Sign up not allowed");
        }
    }
}
