package com.github.lamarios.newsku.errors;

public class NewskuException extends RuntimeException {
    private final String message;

    public NewskuException(String message) {
        this.message = message;
    }

    public String getMessage() {
        return message;
    }
}
