package com.github.lamarios.newsku.security;

import com.github.lamarios.newsku.persistence.entities.User;
import com.github.lamarios.newsku.services.UserService;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

@Component
public class JwtTokenUtil {
    private static final Logger logger = LogManager.getLogger();
    private final SecretKey key;
    private final SecretKey legacyKey;

    public static final long JWT_TOKEN_VALIDITY = 90 * 24 * 60 * 60;
    private static final long serialVersionUID = -2550185165626007488L;


    private final String salt;

//    private final OIDCService oidcService;


    private final UserService userService;

    @Autowired
    public JwtTokenUtil(UserService userService, @Value("${SALT}") String salt) throws Exception {
//        this.oidcService = oidcService;
        this.userService = userService;
        this.salt = salt;

        this.key = deriveKey(salt);
        this.legacyKey = deriveLegacyKey(salt);

    }

    private static SecretKey deriveKey(String salt) throws Exception {
        // PBKDF2WithHmacSHA512 with 100 000 iterations → 512-bit key for HmacSHA512.
        // Static info bytes act as a KDF domain separator; the SALT env var is the password.
        byte[] info = "newsku-jwt-key".getBytes(StandardCharsets.UTF_8);
        PBEKeySpec spec = new PBEKeySpec(salt.toCharArray(), info, 100_000, 512);
        try {
            SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA512");
            byte[] derived = factory.generateSecret(spec).getEncoded();
            return new SecretKeySpec(derived, "HmacSHA512");
        } finally {
            spec.clearPassword();
        }
    }

    // Pre-B4 key derivation. Only used to verify tokens signed before the PBKDF2 migration
    // so that existing sessions survive the upgrade. New tokens are always signed with
    // `key` above. Remove once the 90-day JWT validity window has elapsed post-rollout.
    private static SecretKey deriveLegacyKey(String salt) {
        byte[] saltBytes = salt.getBytes(StandardCharsets.UTF_8);
        if (saltBytes.length < 64) {
            byte[] extended = new byte[64];
            for (int i = 0; i < 64; i++) {
                extended[i] = saltBytes[i % saltBytes.length];
            }
            saltBytes = extended;
        } else if (saltBytes.length > 64) {
            saltBytes = Arrays.copyOf(saltBytes, 64);
        }
        return new SecretKeySpec(saltBytes, "HmacSHA512");
    }


    public String getUsernameFromToken(String token) {
        return getClaimFromToken(token, Claims::getSubject);
    }

    public Date getIssuedAtDateFromToken(String token) {
        return getClaimFromToken(token, Claims::getIssuedAt);
    }

    public Date getExpirationDateFromToken(String token) {
        return getClaimFromToken(token, Claims::getExpiration);
    }

    public <T> T getClaimFromToken(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = getAllClaimsFromToken(token);
        return claimsResolver.apply(claims);
    }

    public Claims getAllClaimsFromToken(String token) {
        try {
            return Jwts.parser().verifyWith(key).build().parseSignedClaims(token).getPayload();
        } catch (Exception primaryFailure) {
            try {
                return Jwts.parser().verifyWith(legacyKey).build().parseSignedClaims(token).getPayload();
            } catch (Exception legacyFailure) {
                throw primaryFailure;
            }
/*
            if (oidcService.getParser() != null) {
                return oidcService.getParser().parseSignedClaims(token).getPayload();
            } else {
*/
//            }
        }
    }

    private Boolean isTokenExpired(String token) {
        final Date expiration = getExpirationDateFromToken(token);
        return expiration.before(new Date());
    }

    private Boolean ignoreTokenExpiration(String token) {
        // here you specify tokens, for that the expiration is ignored
        return false;
    }

    public String generateToken(UserDetails userDetails) {
        try {
            User user = userService.getUser(userDetails.getUsername()).orElseThrow();
            Map<String, Object> userClaim = new HashMap<>();
            userClaim.put("id", user.getId().toString());
            userClaim.put("username", user.getUsername());
            userClaim.put("email", user.getEmail());

            Map<String, Object> claims = new HashMap<>();
            claims.put("user", userClaim);
            return doGenerateToken(claims, userDetails.getUsername());
        } catch (Exception e) {
            logger.error("Failed to generate JWT token for user {}", userDetails.getUsername(), e);
            throw new IllegalStateException("Could not generate authentication token", e);
        }
    }


    public String doGenerateToken(Map<String, Object> claims, String subject) {
        return doGenerateToken(claims, subject, JWT_TOKEN_VALIDITY * 1000);
    }

    public String doGenerateToken(Map<String, Object> claims, String subject, long expiresIn) {
        return Jwts.builder()
                .claims(claims).subject(subject).issuedAt(new Date(System.currentTimeMillis()))
                .issuer("newsku")
                .expiration(new Date(System.currentTimeMillis() + expiresIn)).signWith(key).compact();
    }

    public Boolean canTokenBeRefreshed(String token) {
        return (!isTokenExpired(token) || ignoreTokenExpiration(token));
    }

    public Boolean validateToken(String token, UserDetails userDetails) {
        final String username = getUsernameFromToken(token);
        var user = userService.getUser(userDetails.getUsername());
        return ((username.equals(userDetails.getUsername())/* || username.equalsIgnoreCase(user.getOidcSub())*/) && !isTokenExpired(token));
    }

    public String getSalt() {
        return salt;
    }

}
