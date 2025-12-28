package com.github.lamarios.newsku.models;

public enum EmailDigestFrequency {
    daily(1, "Daily digest"),
    weekly(7, "Weekly digest"), monthly(30, "Monthly digest");

    private final int days;
    private final String emailTitle;

    EmailDigestFrequency(int days, String emailTitle) {
        this.days = days;
        this.emailTitle = emailTitle;
    }

    public int getDays() {
        return days;
    }

    public String getEmailTitle() {
        return emailTitle;
    }
}
