package com.github.lamarios.newsku.controllers;

import com.github.lamarios.newsku.TestConfig;
import com.github.lamarios.newsku.TestContainerTest;
import com.github.lamarios.newsku.models.ReadItemHandling;
import com.github.lamarios.newsku.persistence.entities.User;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;

import java.nio.file.AccessDeniedException;

import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

@Import(TestConfig.class)
public class SignUpControllerTest extends TestContainerTest {
    @Autowired
    private SignUpController signUpController;

    @Test
    public void signUpTest() throws AccessDeniedException {
        User newUser = new User();
        newUser.setPassword("somePassword");
        newUser.setEmail("someEmail@eai.com");
        newUser.setUsername("someUsername");
        newUser.setReadItemHandling(ReadItemHandling.none);

        var user = signUpController.signup(newUser);
        assertNotNull(user.getId());
        // password should be hashed
        assertNotEquals("samePassword", user.getPassword());

    }
}
