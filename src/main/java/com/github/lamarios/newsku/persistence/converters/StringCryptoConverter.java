package com.github.lamarios.newsku.persistence.converters;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * JPA converter for encrypting sensitive string columns at rest with AES-GCM.
 *
 * <p>Key is injected by Spring from the {@code encryptionKey} bean defined in
 * {@link com.github.lamarios.newsku.Config}. No system properties are used.
 *
 * <p>Output layout per value: {@code enc:v1:Base64(iv || ciphertext || gcmTag)}.
 * Null / empty inputs pass through unchanged.
 *
 * <p>Plaintext values already in the database (legacy rows) are transparently
 * returned as-is on read — they will be re-encrypted the next time the entity
 * is saved.
 */
@Component
@Converter
public class StringCryptoConverter implements AttributeConverter<String, String> {

    private static final Logger logger = LogManager.getLogger();

    private static final String ALGORITHM = "AES";
    private static final String TRANSFORMATION = "AES/GCM/NoPadding";
    private static final int IV_LENGTH_BYTES = 12;
    private static final int GCM_TAG_LENGTH_BITS = 128;
    private static final String CIPHERTEXT_PREFIX = "enc:v1:";

    private static final SecureRandom RANDOM = new SecureRandom();

    private final SecretKey key;

    @Autowired
    public StringCryptoConverter(SecretKey encryptionKey) {
        this.key = encryptionKey;
    }

    @Override
    public String convertToDatabaseColumn(String attribute) {
        if (attribute == null || attribute.isEmpty()) {
            return attribute;
        }
        try {
            byte[] iv = new byte[IV_LENGTH_BYTES];
            RANDOM.nextBytes(iv);

            Cipher cipher = Cipher.getInstance(TRANSFORMATION);
            cipher.init(Cipher.ENCRYPT_MODE, key, new GCMParameterSpec(GCM_TAG_LENGTH_BITS, iv));
            byte[] ciphertext = cipher.doFinal(attribute.getBytes(StandardCharsets.UTF_8));

            byte[] combined = new byte[iv.length + ciphertext.length];
            System.arraycopy(iv, 0, combined, 0, iv.length);
            System.arraycopy(ciphertext, 0, combined, iv.length, ciphertext.length);

            return CIPHERTEXT_PREFIX + Base64.getEncoder().encodeToString(combined);
        } catch (Exception e) {
            throw new IllegalStateException("Failed to encrypt value for database column", e);
        }
    }

    @Override
    public String convertToEntityAttribute(String dbData) {
        if (dbData == null || dbData.isEmpty()) {
            return dbData;
        }
        if (!dbData.startsWith(CIPHERTEXT_PREFIX)) {
            // Legacy plaintext row — return as-is; re-encrypted on next write.
            return dbData;
        }
        try {
            byte[] combined = Base64.getDecoder().decode(dbData.substring(CIPHERTEXT_PREFIX.length()));
            if (combined.length <= IV_LENGTH_BYTES) {
                throw new IllegalArgumentException("Ciphertext too short");
            }
            byte[] iv = new byte[IV_LENGTH_BYTES];
            byte[] ciphertext = new byte[combined.length - IV_LENGTH_BYTES];
            System.arraycopy(combined, 0, iv, 0, IV_LENGTH_BYTES);
            System.arraycopy(combined, IV_LENGTH_BYTES, ciphertext, 0, ciphertext.length);

            Cipher cipher = Cipher.getInstance(TRANSFORMATION);
            cipher.init(Cipher.DECRYPT_MODE, key, new GCMParameterSpec(GCM_TAG_LENGTH_BITS, iv));
            byte[] plaintext = cipher.doFinal(ciphertext);
            return new String(plaintext, StandardCharsets.UTF_8);
        } catch (Exception e) {
            logger.error("Failed to decrypt stored credential — returning null. Check APP_ENCRYPTION_KEY.");
            throw new IllegalStateException("Failed to decrypt value from database column", e);
        }
    }
}
