package com.github.lamarios.newsku.logging;

import ch.qos.logback.classic.pattern.ClassicConverter;
import ch.qos.logback.classic.spi.ILoggingEvent;

import java.util.regex.Pattern;

/**
 * Logback converter that masks values of sensitive fields in log messages.
 * Registered as %mask in logback-spring.xml and applied to every log line.
 */
public class SensitiveMaskingConverter extends ClassicConverter {

    private static final String MASK = "***";

    // Matches JSON-style key:"value" and key=value pairs for sensitive fields.
    private static final Pattern SENSITIVE_PATTERN = Pattern.compile(
            "(?i)(\"?(?:password|token|apiKey|api_key|authorization|secret|credential|OPENAI_API_KEY|openai_api_key|GREADER_API_PASSWORD|greader_api_password)\"?\\s*[=:]\\s*)([\"']?)([^\"',;\\s}{\\]\\[]{1,500})\\2",
            Pattern.CASE_INSENSITIVE);

    @Override
    public String convert(ILoggingEvent event) {
        String message = event.getFormattedMessage();
        if (message == null) {
            return "";
        }
        return SENSITIVE_PATTERN.matcher(message).replaceAll(m -> m.group(1) + m.group(2) + MASK + m.group(2));
    }
}
