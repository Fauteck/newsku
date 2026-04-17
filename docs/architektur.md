# Architektur

← [Zurueck zum Index](../CLAUDE.md)

---

## Monorepo-Uebersicht

Newsku ist ein selbst-gehosteter RSS-Reader, der LLMs (OpenAI) nutzt, um Feed-Beitraege nach Relevanz zu sortieren.
Das Repository ist ein Monorepo mit Backend (Java/Spring Boot) und Frontend (Flutter):

```
newsku/
  src/main/java/   → Spring Boot REST API (Java 25)
  src/main/app/    → Flutter App (Web + Android)
  src/main/resources/db/migration/  → Flyway SQL-Migrationen
  docker/          → Dockerfile + Entrypoint
```

---

## Tech Stack

### Backend (`src/main/java/com/github/lamarios/newsku/`)

| Technologie | Version | Zweck |
|-------------|---------|-------|
| Spring Boot | 4.0.1 | HTTP-Server, DI, Auto-Konfiguration |
| Spring Data JPA | — | ORM, Repository-Pattern |
| Spring Security | — | JWT-Authentifizierung, OIDC |
| Flyway | — | Datenbank-Migrationen |
| PostgreSQL JDBC | — | Datenbank-Treiber |
| OpenAI Java SDK | 4.13.0 | LLM-Integration (Ranking) |
| Apptastic RSS Reader | 3.12.0 | RSS/Atom Feed Parsing |
| JJWT | 0.13.0 | JWT-Tokens |
| jsoup | 1.21.2 | HTML-Parsing & -Bereinigung |
| Simple Java Mail | 6.6.1 | E-Mail Digest & Passwort-Reset |
| SpringDoc OpenAPI | 3.0.0 | Swagger-UI (`/swagger-ui.html`) |
| Spring Actuator | — | Health-Endpunkt (`/actuator/health`) |
| TestContainers | 1.21.0 | Integrationstests mit echter DB |

### Frontend (`src/main/app/`)

| Technologie | Version | Zweck |
|-------------|---------|-------|
| Flutter | ^3.10.0 | UI-Framework (Web + Android) |
| flutter_bloc | — | State Management (BLoC-Pattern) |
| auto_route | — | Deklaratives Routing |
| http | — | HTTP-Client fuer API-Aufrufe |
| jwt_decoder | — | JWT-Token Dekodierung |
| oidc | — | OpenID Connect Authentifizierung |
| cached_network_image | — | Bild-Caching |
| dynamic_color | — | Material Design 3 Dynamic Color |
| shared_preferences | — | Lokale Einstellungen |
| intl | — | Internationalisierung |

### Datenbank

| Technologie | Version | Zweck |
|-------------|---------|-------|
| PostgreSQL | 18-alpine | Relationale Datenbank |
| Flyway | — | Schema-Migrationen (V1–V16) |

---

## Request-Flow (API)

```
HTTP Request
  │
  ├─ Spring Security Filter Chain
  │     ├─ JwtAuthFilter (JWT validieren, SecurityContext setzen)
  │     └─ OidcFilter (optional, OIDC-Token validieren)
  │
  ├─ REST Controller (controllers/*.java)
  │     │
  │     ├─ Spring Validation (@Valid, @RequestBody)
  │     │
  │     ├─ Service Layer (services/*.java)
  │     │     ├─ Geschaeftslogik
  │     │     ├─ OpenAI-Integration (OpenaiService)
  │     │     ├─ RSS-Parsing (FeedService)
  │     │     └─ JPA-Repositories (persistence/repositories/)
  │     │
  │     └─ Response (JSON via Jackson)
  │
  └─ Statische Inhalte (Flutter Web Build)
       → StaticContentController
```

---

## Authentifizierung

### JWT-Flow

1. **Login:** `POST /api/users/login` → JWT Access Token
2. **Jeder Request:** `Authorization: Bearer <token>` → JwtAuthFilter validiert
3. **Token-Payload:** `{ sub: userId, email: "..." }`

### OIDC (optional)

- Aktivierung via Konfiguration: OIDC-Provider-URL setzen
- Forward-Auth via OpenID Connect Token
- Route: `POST /api/users/oidc`

### Passwort-Hashing

- BCrypt mit konfigurierbarem `SALT`
- Niemals Klartextpasswoerter speichern

### Credential-Verschluesselung at rest

Zugangsdaten, die wir im Klartext wieder benoetigen (GReader-API-Passwort,
per-User OpenAI-API-Key), werden mit AES-GCM transparent per
`StringCryptoConverter` verschluesselt. Key aus `APP_ENCRYPTION_KEY` (ENV,
Base64, 16/24/32 Byte). Startup schlaegt fehl, wenn der Key fehlt oder
formal ungueltig ist.

---

## LLM-Integration (OpenAI)

Pro Artikel werden **zwei getrennte** OpenAI-Aufrufe ausgefuehrt, damit
Token-Verbrauch und Limits je Use-Case verwaltbar sind:

```
GReaderSyncService.processArticle
  │
  └─ OpenaiService.processFeedItem(user, guid, title, content, tagStats)
       │
       ├─ scoreRelevance    → importance, possibleAd, tags          (use_case = RELEVANCE)
       └─ shortenText       → shortTitle, shortTeaser               (use_case = SHORTENING)
              (nur wenn users.enable_text_shortening != false)

Pro Call:
  1. OpenaiUsageService.isLimitExceeded(user, useCase)  → ggf. Skip
  2. OpenAI API aufrufen (Chat Completion, strukturierte Response)
  3. OpenaiUsageService.record(user, useCase, tokens…)  → openai_usage
```

- Per-User-API-Key/Model/URL ueberschreibt `OPENAI_API_KEY` / `OPENAI_MODEL`
  / `OPENAI_URL` aus der Umgebung.
- Monats-Limits (`users.openai_monthly_token_limit_{relevance,shortening}`):
  hart blockend, werden mit Beginn des naechsten UTC-Monats zurueckgesetzt.
- Stats-Endpoint: `GET /api/openai/usage[?from=&to=]`.

Der `ScheduleService` triggert Feed-Updates und LLM-Ranking periodisch.

---

## Deployment-Architektur

```
Developer
  │
  ├─ Feature-Branch → PR → Merge in main
  │
  ├─ GitHub Actions (Self-Hosted Runner)
  │     → mvn clean package -DskipTests
  │     → Docker Build (docker/Dockerfile)
  │     → Push nach GHCR (Tags: latest + SHA)
  │
  └─ Portainer (GitOps Polling)
       → docker-compose.yml aus docker-configs Repo
       → Automatisches Redeploy bei Aenderungen
```

- **Registry:** `ghcr.io/fauteck/newsku`
- **Image-Tags:** `latest` + kurzer SHA-Commit-Hash
- **Kein SemVer / keine Git-Tags** fuer Image-Releases
- **Laufzeit:** Amazon Corretto 25 (JVM), Port 8080

---

## Verwandte Dokumente

- [README.md](../README.md) — Feature-Uebersicht, Setup
- [docs/datenbank.md](datenbank.md) — Flyway-Schema, Tabellen, Beziehungen
- [docs/api-patterns.md](api-patterns.md) — Controller-Struktur, Services
- [docs/entwicklung.md](entwicklung.md) — Lokales Setup
