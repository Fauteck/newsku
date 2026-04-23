package com.github.lamarios.newsku;


import com.github.benmanes.caffeine.cache.Caffeine;
import freemarker.template.TemplateExceptionHandler;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeIn;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import org.flywaydb.core.Flyway;
import org.hazlewood.connor.bottema.emailaddress.EmailAddressCriteria;
import org.simplejavamail.api.mailer.Mailer;
import org.simplejavamail.api.mailer.config.TransportStrategy;
import org.simplejavamail.mailer.MailerBuilder;
import org.simplejavamail.mailer.internal.MailerRegularBuilderImpl;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.caffeine.CaffeineCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import javax.sql.DataSource;
import java.io.IOException;
import java.util.Base64;
import java.util.concurrent.TimeUnit;

import jakarta.annotation.PostConstruct;

@Configuration
@EnableCaching
@SecurityScheme(
        name = "bearerAuth",
        description = "JWT Authorization header using the Bearer scheme. Example: \"Authorization: Bearer {token}\"",
        scheme = "bearer",
        type = SecuritySchemeType.HTTP,
        bearerFormat = "JWT",
        in = SecuritySchemeIn.HEADER
)
public class Config {

    @Value("${SMTP_USERNAME:}")
    private String smtpUsername;
    @Value("${SMTP_PASSWORD:}")
    private String smtpPassword;
    @Value("${SMTP_HOST:}")
    private String smtpHost;
    @Value("${SMTP_PORT:0}")
    private int smtpPort;
    @Value("${SMTP_TRANSPORT_STRATEGY:SMTP}")
    private TransportStrategy transportStrategy;

    @Value("${ROOT_URL:http://localhost:8080}")
    private String rootUrl;

    @Value("${APP_ENCRYPTION_KEY:}")
    private String appEncryptionKey;

    /**
     * Validates that {@code APP_ENCRYPTION_KEY} is set and well-formed.
     * Credentials at rest (GReader password, OpenAI API key) are encrypted
     * with this key via {@link com.github.lamarios.newsku.persistence.converters.StringCryptoConverter}.
     */
    @PostConstruct
    public void validateEncryptionKey() {
        if (appEncryptionKey == null || appEncryptionKey.isBlank()) {
            throw new IllegalStateException(
                    "APP_ENCRYPTION_KEY must be set. Generate one with: openssl rand -base64 32");
        }
        byte[] raw;
        try {
            raw = Base64.getDecoder().decode(appEncryptionKey.trim());
        } catch (IllegalArgumentException e) {
            throw new IllegalStateException(
                    "APP_ENCRYPTION_KEY must be Base64. Generate with: openssl rand -base64 32", e);
        }
        if (raw.length != 16 && raw.length != 24 && raw.length != 32) {
            throw new IllegalStateException(
                    "APP_ENCRYPTION_KEY must decode to 16, 24 or 32 bytes (got " + raw.length + ").");
        }
        // Propagate to system property so JPA converter can read it in any context.
        System.setProperty("APP_ENCRYPTION_KEY", appEncryptionKey.trim());
    }

    @Bean
    public String rootUrl() {
        return rootUrl;
    }

    @Bean
    public PasswordEncoder encoder() {
        return new BCryptPasswordEncoder();
    }

    /**
     * Short-TTL read-through cache for hot lookup paths (issue B17).
     * Each authenticated request resolves the current user + feed list, which
     * otherwise triggers the same queries dozens of times per request chain.
     * 60 s is short enough that mutations are visible almost immediately;
     * explicit {@code @CacheEvict} annotations on mutating service methods
     * still take precedence.
     */
    @Bean
    public CacheManager cacheManager() {
        CaffeineCacheManager manager = new CaffeineCacheManager(
                "users", "feedsByUser", "feedCategoriesByUser");
        manager.setCaffeine(Caffeine.newBuilder()
                .expireAfterWrite(60, TimeUnit.SECONDS)
                .maximumSize(10_000));
        return manager;
    }

    @Bean(name = "flyway")
    public Flyway flyway(
            DataSource dataSource,
            @Value("${spring.flyway.locations}") String locations,
            @Value("${spring.flyway.baseline-on-migrate:false}") boolean baselineOnMigrate
    ) {
        Flyway flyway = Flyway.configure()
                .dataSource(dataSource)
                .locations(locations)
                .baselineOnMigrate(baselineOnMigrate)
                .load();

        flyway.migrate(); // Force migration to run
        return flyway;
    }


    @Bean
    public Mailer mailer() {
        MailerRegularBuilderImpl mailer;
        if (smtpHost == null || smtpPort == 0 || smtpHost.trim().isEmpty()) {
            return null;
        }

        if (smtpUsername != null && !smtpUsername.isEmpty()) {
            if (smtpPassword == null || smtpPassword.trim().isEmpty()) {
                mailer = MailerBuilder.withSMTPServer(smtpHost, smtpPort, smtpUsername);
            } else {
                mailer = MailerBuilder.withSMTPServer(smtpHost, smtpPort, smtpUsername, smtpPassword);
            }
        } else {
            mailer = MailerBuilder.withSMTPServer(smtpHost, smtpPort);
        }


        mailer = mailer.withTransportStrategy(transportStrategy);

        mailer = mailer.clearEmailAddressCriteria()
                .async()
                .withEmailAddressCriteria(EmailAddressCriteria.RFC_COMPLIANT);
        return mailer.buildMailer();
    }


    @Bean
    public freemarker.template.Configuration templateEngine() throws IOException {
        // Create your Configuration instance, and specify if up to what FreeMarker
        // version (here 2.3.29) do you want to apply the fixes that are not 100%
        // backward-compatible. See the Configuration JavaDoc for details.
        freemarker.template.Configuration cfg = new freemarker.template.Configuration(freemarker.template.Configuration.VERSION_2_3_29);

        // Specify the source where the template files come from. Here I set a
        // plain directory for it, but non-file-system sources are possible too:
        cfg.setClassForTemplateLoading(this.getClass(), "/templates/");

        // From here we will set the settings recommended for new projects. These
        // aren't the defaults for backward compatibilty.

        // Set the preferred charset template files are stored in. UTF-8 is
        // a good choice in most applications:
        cfg.setDefaultEncoding("UTF-8");

        // Sets how errors will appear.
        // During web page *development* TemplateExceptionHandler.HTML_DEBUG_HANDLER is better.
        cfg.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER);

        // Don't log exceptions inside FreeMarker that it will thrown at you anyway:
        cfg.setLogTemplateExceptions(false);

        // Wrap unchecked exceptions thrown during template processing into TemplateException-s:
        cfg.setWrapUncheckedExceptions(true);

        // Do not fall back to higher scopes when reading a null loop variable:
        cfg.setFallbackOnNullLoopVariable(false);

        return cfg;
    }
}
