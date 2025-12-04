package com.github.lamarios.newsku.models;

public enum LayoutBlockType {
    bigHeadline(true), topStories(true), bigGrid(false), smallGrid(false);


    private final boolean fixedSize;

    LayoutBlockType(boolean fixedSize) {
        this.fixedSize = fixedSize;
    }

    public boolean isFixedSize() {
        return fixedSize;
    }
}
