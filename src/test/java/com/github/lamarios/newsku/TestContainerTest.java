package com.github.lamarios.newsku;

import com.github.lamarios.newsku.controllers.SignUpController;
import com.github.lamarios.newsku.errors.NewskuUserException;
import com.github.lamarios.newsku.models.ReadItemHandling;
import com.github.lamarios.newsku.persistence.entities.User;
import com.github.lamarios.newsku.persistence.repositories.UserRepository;
import com.github.lamarios.newsku.services.UserService;
import com.github.lamarios.newsku.utils.TestUserService;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.nio.file.AccessDeniedException;


@SuppressWarnings("SpringBootApplicationProperties")
@SpringBootTest(classes = Application.class, properties = {
        "spring.main.allow-bean-definition-overriding=true",
        "ALLOW_SIGNUP=1",
        // Deterministic AES-256 key for tests (32 bytes → 44 Base64 chars).
        "APP_ENCRYPTION_KEY=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
}, webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
abstract public class TestContainerTest {

    @Autowired
    private SignUpController signUpController;

    private final static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:18");

    static {
        postgres.start();
    }

    @Autowired
    private UserService userService;
    @Autowired
    private UserRepository userRepository;


    @DynamicPropertySource
    static void configureSQLContainer(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
        registry.add("spring.flyway.url", postgres::getJdbcUrl);
        registry.add("spring.flyway.user", postgres::getUsername);
        registry.add("spring.flyway.password", postgres::getPassword);
    }

    @AfterEach
    public void cleaningDB() {
        userRepository.deleteAll();
    }

    @BeforeEach
    public void insertBaseData() throws AccessDeniedException, NewskuUserException {
        User user = new User();
        user.setPassword("test");
        user.setUsername("test");
        user.setEmail("test@test.com");
        user.setReadItemHandling(ReadItemHandling.none);
        user = signUpController.signup(user);

        ((TestUserService) userService).setCurrentUser(user);

    }

}
