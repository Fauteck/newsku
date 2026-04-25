# Architecture

← [Back to Index](../CLAUDE.md)

---

## Monorepo Overview

Newsku is a self-hosted RSS reader that uses LLMs (OpenAI) to sort feed articles by relevance.
The repository is a monorepo containing backend (Java/Spring Boot) and frontend (Flutter):

```
newsku/
  src/main/java/   → Spring Boot REST API (Java 25)
  src/main/app/    → Flutter App (Web + Android)
  src/main/resources/db/migration/  → Flyway SQL migrations
  docker/          → Dockerfile + entrypoint
```

---

## Tech Stack

### Backend (`src/main/java/com/github/lamarios/newsku/`)

| Technology | Version | Purpose |
|------------|---------|---------|
| Spring Boot | 4.0.1 | HTTP server, DI, auto-configuration |
| Spring Data JPA | — | ORM, repository pattern |
| Spring Security | — | JWT authentication, OIDC |
| Flyway | — | Database migrations |
| PostgreSQL JDBC | — | Database driver |
| OpenAI Java SDK | 4.13.0 | LLM integration (ranking) |
| Apptastic RSS Reader | 3.12.0 | RSS/Atom feed parsing |
| JJWT | 0.13.0 | JWT tokens |
| jsoup | 1.21.2 | HTML parsing & sanitisation |
| Simple Java Mail | 6.6.1 | Email digest & password reset |
| SpringDoc OpenAPI | 3.0.0 | Swagger UI (`/swagger-ui.html`) |
| Spring Actuator | — | Health endpoint (`/actuator/health`) |
| TestContainers | 1.21.0 | Integration tests with real DB |

### Frontend (`src/main/app/`)

| Technology | Version | Purpose |
|------------|---------|---------|
| Flutter | ^3.10.0 | UI framework (Web + Android) |
| flutter_bloc | — | State management (BLoC pattern) |
| auto_route | — | Declarative routing |
| http | — | HTTP client for API calls |
| jwt_decoder | — | JWT token decoding |
| oidc | — | OpenID Connect authentication |
| cached_network_image | — | Image caching |
| dynamic_color | — | Material Design 3 Dynamic Color |
| shared_preferences | — | Local settings |
| intl | — | Internationalisation |

### Database

| Technology | Version | Purpose |
|------------|---------|---------|
| PostgreSQL | 18-alpine | Relational database |
| Flyway | — | Schema migrations (V1–V16) |

---

## Request Flow (API)

```
HTTP Request
  │
  ├─ Spring Security Filter Chain
  │     ├─ JwtAuthFilter (validate JWT, set SecurityContext)
  │     └─ OidcFilter (optional, validate OIDC token)
  │
  ├─ REST Controller (controllers/*.java)
  │     │
  │     ├─ Spring Validation (@Valid, @RequestBody)
  │     │
  │     ├─ Service Layer (services/*.java)
  │     │     ├─ Business logic
  │     │     ├─ OpenAI integration (OpenaiService)
  │     │     ├─ RSS parsing (FeedService)
  │     │     └─ JPA repositories (persistence/repositories/)
  │     │
  │     └─ Response (JSON via Jackson)
  │
  └─ Static content (Flutter Web Build)
       → StaticContentController
```

---

## Authentication

### JWT Flow

1. **Login:** `POST /api/users/login` → JWT access token
2. **Every request:** `Authorization: Bearer <token>` → JwtAuthFilter validates
3. **Token payload:** `{ sub: userId, email: "..." }`

### OIDC (optional)

- Activation via configuration: set OIDC provider URL
- Forward-auth via OpenID Connect token
- Route: `POST /api/users/oidc`

### Password Hashing

- BCrypt with configurable `SALT`
- Never store plaintext passwords

### Credential Encryption at Rest

Credentials that need to be retrieved in plaintext (GReader API password,
per-user OpenAI API key) are transparently encrypted with AES-GCM via
`StringCryptoConverter`. Key from `APP_ENCRYPTION_KEY` (ENV, Base64, 16/24/32 bytes).
Startup fails if the key is missing or formally invalid.

---

## LLM Integration (OpenAI)

Two **separate** OpenAI calls are made per article so token consumption and
limits are manageable per use case:

```
GReaderSyncService.processArticle
  │
  └─ OpenaiService.processFeedItem(user, guid, title, content, tagStats)
       │
       ├─ scoreRelevance    → importance, possibleAd, tags          (use_case = RELEVANCE)
       └─ shortenText       → shortTitle, shortTeaser               (use_case = SHORTENING)
              (only when users.enable_text_shortening != false)

Per call:
  1. OpenaiUsageService.isLimitExceeded(user, useCase)  → skip if over limit
  2. Call OpenAI API (chat completion, structured response)
  3. OpenaiUsageService.record(user, useCase, tokens…)  → openai_usage
```

- Per-user API key/model/URL overrides `OPENAI_API_KEY` / `OPENAI_MODEL`
  / `OPENAI_URL` from the environment.
- Monthly limits (`users.openai_monthly_token_limit_{relevance,shortening}`):
  hard-blocking, reset at the start of the next UTC month.
- Stats endpoint: `GET /api/openai/usage[?from=&to=]`.

`ScheduleService` triggers feed updates and LLM ranking periodically.

---

## Deployment Architecture

```
Developer
  │
  ├─ Feature branch → PR → merge to main
  │
  ├─ GitHub Actions (self-hosted runner)
  │     → mvn clean package -DskipTests
  │     → Docker build (docker/Dockerfile)
  │     → Push to GHCR (tags: latest + SHA)
  │
  └─ Portainer (GitOps polling)
       → docker-compose.yml from docker-configs repo
       → Automatic redeploy on changes
```

- **Registry:** `ghcr.io/fauteck/newsku`
- **Image tags:** `latest` + short SHA commit hash
- **No SemVer / no Git tags** for image releases
- **Runtime:** Amazon Corretto 25 (JVM), port 8080

---

## Related Documents

- [README.md](../README.md) — Feature overview, setup
- [docs/datenbank.md](datenbank.md) — Flyway schema, tables, relationships
- [docs/api-patterns.md](api-patterns.md) — Controller structure, services
- [docs/entwicklung.md](entwicklung.md) — Local setup
