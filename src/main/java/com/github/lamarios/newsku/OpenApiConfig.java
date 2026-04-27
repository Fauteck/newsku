package com.github.lamarios.newsku;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * F6: Activates Springdoc OpenAPI with a Bearer-token security scheme so the
 * many controllers already annotated with {@code @SecurityRequirement(name =
 * "bearerAuth")} can actually be exercised from the rendered Swagger UI.
 *
 * Access to {@code /swagger-ui.html} and {@code /v3/api-docs/**} is gated by
 * Spring Security to authenticated users only — see {@link com.github.lamarios.newsku.security.WebSecurityConfig}.
 * The robots.txt also disallows both paths.
 */
@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI newskuOpenApi() {
        return new OpenAPI()
                .info(new Info()
                        .title("Newsku API")
                        .description("REST API for the Newsku self-hosted news reader")
                        .version("v1")
                        .license(new License().name("See repository LICENSE")))
                .components(new Components()
                        .addSecuritySchemes("bearerAuth", new SecurityScheme()
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")
                                .description("JWT obtained from the /authenticate endpoint")));
    }
}
