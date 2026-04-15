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

---

## LLM-Integration (OpenAI)

```
FeedService (RSS abrufen + Items speichern)
  │
  └─ OpenaiService.rankItems(userId, items)
       │
       ├─ Benutzer-Praeferenzen laden (UserService)
       ├─ OpenAI API aufrufen (Chat Completion)
       │     → Model: OPENAI_MODEL (env)
       │     → Endpoint: OPENAI_URL (env, default: openai.com)
       └─ importance_score pro Item speichern
```

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
