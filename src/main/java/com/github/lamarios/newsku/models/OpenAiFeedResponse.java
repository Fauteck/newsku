package com.github.lamarios.newsku.models;

public record OpenAiFeedResponse(
        int importance,
        boolean possibleAd,
        String reasoning
) {
}
