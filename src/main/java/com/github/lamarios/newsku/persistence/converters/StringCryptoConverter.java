package com.github.lamarios.newsku.persistence.converters;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * JPA converter for encrypting sensitive string columns at rest with AES-GCM.
 *
 * <p>Key source: environment variable {@code APP_ENCRYPTION_KEY} (Base64, 32
 * bytes raw). Missing or invalid keys cause a fail-fast at first use.
 *
 * <p>Output layout per value: {@code Base64(iv || ciphertext || gcmTag)}.
 * Null / empty inputs pass through unchanged.
 *
 * <p>Plaintext values already in the database (legacy rows) are transparently
 * returned as-is on read — they will be re-encrypted the next time the entity
 * is saved. Migration of existing data happens lazily through normal writes.
 */
@Converter
public class StringCryptoConverter implements AttributeConverter<String, String> {

    private static final Logger logger = LogManager.getLogger();

    private static final String ALGORITHM = "AES";
    private static final String TRANSFORMATION = "AES/GCM/NoPadding";
    private static final int IV_LENGTH_BYTES = 12;
    private static final int GCM_TAG_LENGTH_BITS = 128;
    private static final String CIPHERTEXT_PREFIX = "enc:v1:";

    private static final SecureRandom RANDOM = new SecureRandom();
    private static volatile SecretKey cachedKey;

    @Override
    public String convertToDatabaseColumn(String attribute) {
        if (attribute == null || attribute.isEmpty()) {
            return attribute;
        }
        try {
            SecretKey key = getKey();
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
            // Legacy plaintext row — return as-is so the app keeps working.
            // Will be re-encrypted on the next write of this entity.
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
            cipher.init(Cipher.DECRYPT_MODE, getKey(), new GCMParameterSpec(GCM_TAG_LENGTH_BITS, iv));
            byte[] plaintext = cipher.doFinal(ciphertext);
            return new String(plaintext, StandardCharsets.UTF_8);
        } catch (Exception e) {
            logger.error("Failed to decrypt stored credential — returning null. Check APP_ENCRYPTION_KEY.");
            throw new IllegalStateException("Failed to decrypt value from database column", e);
        }
    }

    private static SecretKey getKey() {
        SecretKey key = cachedKey;
        if (key != null) {
            return key;
        }
        synchronized (StringCryptoConverter.class) {
            if (cachedKey != null) {
                return cachedKey;
            }
            String keyB64 = System.getenv("APP_ENCRYPTION_KEY");
            if (keyB64 == null || keyB64.isBlank()) {
                keyB64 = System.getProperty("APP_ENCRYPTION_KEY");
            }
            if (keyB64 == null || keyB64.isBlank()) {
                throw new IllegalStateException(
                        "APP_ENCRYPTION_KEY environment variable is not set. "
                                + "Generate one with: openssl rand -base64 32");
            }
            byte[] raw;
            try {
                raw = Base64.getDecoder().decode(keyB64.trim());
            } catch (IllegalArgumentException e) {
                throw new IllegalStateException(
                        "APP_ENCRYPTION_KEY is not valid Base64. Generate with: openssl rand -base64 32", e);
            }
            if (raw.length != 16 && raw.length != 24 && raw.length != 32) {
                throw new IllegalStateException(
                        "APP_ENCRYPTION_KEY must decode to 16, 24 or 32 bytes (got " + raw.length + ").");
            }
            cachedKey = new SecretKeySpec(raw, ALGORITHM);
            return cachedKey;
        }
    }

    /** Visible for testing — resets the cached key so a test can swap the env var. */
    static void resetKeyCacheForTests() {
        cachedKey = null;
    }
}
