package com.github.lamarios.newsku.errors;

/**
 * Thrown when a user tries to subscribe to a feed URL they have already
 * subscribed to. Mapped to HTTP 409 by NewskuUserExceptionHandler.
 */
public class DuplicateFeedException extends NewskuException {
    public DuplicateFeedException(String message) {
        super(message);
    }
}
