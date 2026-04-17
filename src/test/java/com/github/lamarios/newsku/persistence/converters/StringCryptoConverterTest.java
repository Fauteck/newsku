package com.github.lamarios.newsku.persistence.converters;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Round-trip tests for the AES-GCM JPA converter used to encrypt
 * credentials at rest. Runs without Spring context — sets
 * {@code APP_ENCRYPTION_KEY} as a system property.
 */
class StringCryptoConverterTest {

    private static final String TEST_KEY_B64 = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; // 32 zero bytes, AES-256

    private String previousKey;

    @BeforeEach
    void setKey() {
        previousKey = System.getProperty("APP_ENCRYPTION_KEY");
        System.setProperty("APP_ENCRYPTION_KEY", TEST_KEY_B64);
        StringCryptoConverter.resetKeyCacheForTests();
    }

    @AfterEach
    void restoreKey() {
        if (previousKey != null) {
            System.setProperty("APP_ENCRYPTION_KEY", previousKey);
        } else {
            System.clearProperty("APP_ENCRYPTION_KEY");
        }
        StringCryptoConverter.resetKeyCacheForTests();
    }

    @Test
    void roundTripReturnsOriginal() {
        StringCryptoConverter c = new StringCryptoConverter();
        String original = "super-secret-greader-password!";
        String encrypted = c.convertToDatabaseColumn(original);
        assertNotEquals(original, encrypted);
        assertTrue(encrypted.startsWith("enc:v1:"), "ciphertext must carry version prefix");
        assertEquals(original, c.convertToEntityAttribute(encrypted));
    }

    @Test
    void encryptionIsNonDeterministic() {
        StringCryptoConverter c = new StringCryptoConverter();
        String input = "same-value";
        String a = c.convertToDatabaseColumn(input);
        String b = c.convertToDatabaseColumn(input);
        assertNotEquals(a, b, "IV must be random — identical inputs must produce different ciphertexts");
        assertEquals(input, c.convertToEntityAttribute(a));
        assertEquals(input, c.convertToEntityAttribute(b));
    }

    @Test
    void nullAndEmptyPassThrough() {
        StringCryptoConverter c = new StringCryptoConverter();
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
        StringCryptoConverter c = new StringCryptoConverter();
        String legacy = "plaintext-from-older-version";
        assertEquals(legacy, c.convertToEntityAttribute(legacy));
    }

    @Test
    void missingKeyFailsLoudly() {
        System.clearProperty("APP_ENCRYPTION_KEY");
        StringCryptoConverter.resetKeyCacheForTests();
        StringCryptoConverter c = new StringCryptoConverter();
        assertThrows(IllegalStateException.class, () -> c.convertToDatabaseColumn("anything"));
    }

    @Test
    void invalidBase64KeyFailsLoudly() {
        System.setProperty("APP_ENCRYPTION_KEY", "not-base64!!!***");
        StringCryptoConverter.resetKeyCacheForTests();
        StringCryptoConverter c = new StringCryptoConverter();
        assertThrows(IllegalStateException.class, () -> c.convertToDatabaseColumn("anything"));
    }

    @Test
    void wrongKeyLengthFailsLoudly() {
        // 10 bytes — neither 16, 24 nor 32
        System.setProperty("APP_ENCRYPTION_KEY", java.util.Base64.getEncoder().encodeToString(new byte[10]));
        StringCryptoConverter.resetKeyCacheForTests();
        StringCryptoConverter c = new StringCryptoConverter();
        assertThrows(IllegalStateException.class, () -> c.convertToDatabaseColumn("anything"));
    }
}
