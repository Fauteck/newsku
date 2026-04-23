package com.github.lamarios.newsku.persistence.repositories;

import com.github.lamarios.newsku.persistence.entities.PasswordResetToken;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PasswordResetTokenRepository extends JpaRepository<PasswordResetToken, String> {
}
