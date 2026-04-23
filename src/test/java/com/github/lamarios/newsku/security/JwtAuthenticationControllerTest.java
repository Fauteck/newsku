package com.github.lamarios.newsku.security;

import com.github.lamarios.newsku.TestConfig;
import com.github.lamarios.newsku.TestContainerTest;
import com.github.lamarios.newsku.models.UserCredentials;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Import;
import org.springframework.mock.web.MockHttpServletRequest;

import static org.junit.jupiter.api.Assertions.*;

@Import(TestConfig.class)
public class JwtAuthenticationControllerTest extends TestContainerTest {
    @Autowired
    private JwtAuthenticationController jwtAuthenticationController;

    @Test
    public void loginTest() throws Exception {
        var request = new MockHttpServletRequest();
        var token = jwtAuthenticationController.login(new UserCredentials("test", "test"), request);

        assertNotNull(token);
        assertFalse(token.isEmpty());

        assertThrows(Exception.class, () -> jwtAuthenticationController.login(new UserCredentials("test", "wrongpassword"), request));

    }
}
