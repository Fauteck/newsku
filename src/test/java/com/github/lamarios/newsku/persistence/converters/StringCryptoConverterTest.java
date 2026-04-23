package com.github.lamarios.newsku.persistence.converters;

import org.junit.jupiter.api.Test;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.util.Base64;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Round-trip tests for the AES-GCM JPA converter used to encrypt
 * credentials at rest. Runs without Spring context — the {@link SecretKey}
 * is built directly from a deterministic test key.
 */
class StringCryptoConverterTest {

    private static final String TEST_KEY_B64 = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; // 32 zero bytes, AES-256

    private static SecretKey testKey() {
        return new SecretKeySpec(Base64.getDecoder().decode(TEST_KEY_B64), "AES");
    }

    @Test
    void roundTripReturnsOriginal() {
        StringCryptoConverter c = new StringCryptoConverter(testKey());
        String original = "super-secret-greader-password!";
        String encrypted = c.convertToDatabaseColumn(original);
        assertNotEquals(original, encrypted);
        assertTrue(encrypted.startsWith("enc:v1:"), "ciphertext must carry version prefix");
        assertEquals(original, c.convertToEntityAttribute(encrypted));
    }

    @Test
    void encryptionIsNonDeterministic() {
        StringCryptoConverter c = new StringCryptoConverter(testKey());
        String input = "same-value";
        String a = c.convertToDatabaseColumn(input);
        String b = c.convertToDatabaseColumn(input);
        assertNotEquals(a, b, "IV must be random — identical inputs must produce different ciphertexts");
        assertEquals(input, c.convertToEntityAttribute(a));
        assertEquals(input, c.convertToEntityAttribute(b));
    }

    @Test
    void nullAndEmptyPassThrough() {
        StringCryptoConverter c = new StringCryptoConverter(testKey());
        assertNull(c.convertToDatabaseColumn(null));
        assertNull(c.convertToEntityAttribute(null));
        assertEquals("", c.convertToDatabaseColumn(""));
        assertEquals("", c.convertToEntityAttribute(""));
    }

    @Test
    void legacyPlaintextIsReadableAsIs() {
        // Rows that exist from before encryption was introduced have no prefix
        // and should round-trip readable so the app keeps working until the
        // next save re-encrypts them.
        StringCryptoConverter c = new StringCryptoConverter(testKey());
        String legacy = "plaintext-from-older-version";
        assertEquals(legacy, c.convertToEntityAttribute(legacy));
    }
}
