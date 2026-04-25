package com.github.lamarios.newsku.services;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.github.lamarios.newsku.models.OIDCConfig;
import com.github.lamarios.newsku.persistence.entities.User;
import io.jsonwebtoken.Identifiable;
import io.jsonwebtoken.JwtParser;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Jwk;
import io.jsonwebtoken.security.Jwks;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.Optional;
import java.util.Random;

import static java.util.stream.Collectors.toMap;

@Service
public class OidcService implements ApplicationContextAware {
    @Value("${OIDC_DISCOVERY_URL:}")
    private String oidcDiscoveryUrl;

    @Value("${OIDC_AUTO_SIGNUP_USERS:0}")
    private boolean autoSignUpUsers;

    @Value("${OIDC_CLIENT_ID:}")
    private String clientId;

    @Value("${OIDC_EMAIL_CLAIM:email}")
    private String oidcEmailClaim;
    @Value("${OIDC_USERNAME_CLAIM:preferred_username}")
    private String oidcPreferredUsernameClaim;

    @Value("${OIDC_NAME:SSO}")
    private String oidcName;

    private JwtParser parser;

    private OIDCConfig oidcConfig;

    private final ObjectMapper objectMapper = new ObjectMapper();

    private final UserService userService;
    private final RestClient restClient;

    @Autowired
    public OidcService(UserService userService, RestClient.Builder restClientBuilder) {
        this.userService = userService;
        this.restClient = restClientBuilder.build();
        objectMapper.disable(DeserializationFeature.FAIL_ON_IGNORED_PROPERTIES, DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES);
    }

    public String getOidcDiscoveryUrl() {
        return oidcDiscoveryUrl;
    }

    public OIDCConfig getOidcConfig() {
        return oidcConfig;
    }

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {

        if (oidcDiscoveryUrl != null && !oidcDiscoveryUrl.isBlank()) {
            try {
                String discoveryBody = restClient.get().uri(oidcDiscoveryUrl)
                        .retrieve().body(String.class);
                oidcConfig = objectMapper.readValue(discoveryBody, OIDCConfig.class);

                String jwksBody = restClient.get().uri(oidcConfig.getJwksUri())
                        .retrieve().body(String.class);

                oidcConfig.setDiscoveryUrl(oidcDiscoveryUrl);
                oidcConfig.setClientId(clientId);
                oidcConfig.setEmailClaim(oidcEmailClaim);
                oidcConfig.setUsernameClaim(oidcPreferredUsernameClaim);
                oidcConfig.setName(oidcName);

                var keyMap = Jwks.setParser()
                        .build()
                        .parse(jwksBody)
                        .getKeys()
                        .stream()
                        .collect(toMap(Identifiable::getId, Jwk::toKey));

                parser = Jwts.parser()
                        .keyLocator(header -> keyMap.get(header.getOrDefault("kid", "").toString()))
                        .build();

            } catch (RestClientException | JsonProcessingException e) {
                throw new RuntimeException(e);
            }
        }
    }


    public JwtParser getParser() {
        return parser;
    }

    public void setParser(JwtParser parser) {
        this.parser = parser;
    }

    public String getOidcEmailClaim() {
        return oidcEmailClaim;
    }

    public Optional<User> handleUserSub(String sub, String accessToken) throws Exception {
        // check DB if we have a user with this sub
        var userOpt = userService.getByOidcSub(sub);

        // if we don't get the info
        if (userOpt.isEmpty()) {

            JsonNode object = restClient.get().uri(oidcConfig.getUserInfoUrl())
                    .header("Authorization", "Bearer " + accessToken)
                    .retrieve().body(JsonNode.class);

            if (object != null && object.has(oidcPreferredUsernameClaim)) {
                var user = userService.getUser(object.get(oidcPreferredUsernameClaim).asText()).orElse(null);

                // if we still don't have  auser we might need to sign it up
                if (user != null) {
                    user.setOidcSub(sub);
                    return Optional.ofNullable(userService.updateUser(user));
                } else if (autoSignUpUsers) {

                    byte[] array = new byte[50]; // length is bounded by 7
                    new Random().nextBytes(array);
                    String generatedString = new String(array, StandardCharsets.UTF_8);

                    user = new User();
                    user.setOidcSub(sub);
                    user.setPassword(RandomStringUtils.secure().nextAlphabetic(70));
                    user.setEmail(object.get(oidcEmailClaim).asText());
                    user.setUsername(object.get(oidcPreferredUsernameClaim).asText());

                    return Optional.ofNullable(userService.createUser(user));
                } else {
                    throw new Exception();
                }

            } else {
                throw new Exception();
            }

        } else {
            return userOpt;
        }
    }
}
