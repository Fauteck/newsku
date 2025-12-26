package com.github.lamarios.newsku.services;

import com.github.lamarios.newsku.errors.NewskuUserException;
import com.github.lamarios.newsku.persistence.entities.User;
import com.github.lamarios.newsku.persistence.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.SQLException;
import java.util.Optional;
import java.util.UUID;

@Service
public class UserService {

    private final UserRepository userRepository;

    private final PasswordEncoder passwordEncoder;

    @Autowired
    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Transactional(readOnly = true)
    public Optional<User> getUser(String username) {
        return userRepository.getUserByUsername(username).stream().findFirst();
    }


    @Transactional(readOnly = true)
    public User getCurrentUser() {
        final Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        assert authentication != null;
        org.springframework.security.core.userdetails.User user = (org.springframework.security.core.userdetails.User) authentication.getPrincipal();

        assert user != null;
        return getUser(user.getUsername()).orElseThrow();
    }

    @Transactional
    public User createUser(User user) throws NewskuUserException {
        user.setId(UUID.randomUUID().toString());

        boolean emailUsed = userRepository.countUserByEmail(user.getEmail()) > 0;
        boolean usernameUsed = userRepository.countUserByUsername(user.getUsername()) > 0;

        if (emailUsed) {
            try {
                // we sleep to limit email scanning
                Thread.sleep(2000);
            } catch (InterruptedException _) {

            }
            throw new NewskuUserException("Email already taken");
        }

        if (usernameUsed) {
            try {
                // we sleep to limit email scanning
                Thread.sleep(2000);
            } catch (InterruptedException _) {

            }
            throw new NewskuUserException("Username already taken");
        }

        // hash password
        if (user.getPassword() != null) {
            user.setPassword(passwordEncoder.encode(user.getPassword()));
        }

        return userRepository.save(user);
    }

    public Optional<User> getByOidcSub(String sub) {
        return Optional.ofNullable(userRepository.getUserByOidcSub(sub));
    }

    public User updateUser(User user) {
        return userRepository.save(user);
    }

    @Transactional
    public User updateSelf(User user) {
        User currentUser = getCurrentUser();
        if (currentUser.getId().equalsIgnoreCase(user.getId())) {
            // we update the password if it has changed
            if (user.getPassword() != null && !user.getPassword().trim().isBlank() && !currentUser.getPassword()
                    .equalsIgnoreCase(user.getPassword())) {
                user.setPassword(passwordEncoder.encode(user.getPassword()));
            } else {
                user.setPassword(currentUser.getPassword());
            }

            return updateUser(user);
        } else {
            throw new AccessDeniedException("You can only edit yourself");
        }
    }
}
