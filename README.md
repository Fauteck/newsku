# Newsku

[![Build](https://github.com/fauteck/newsku/actions/workflows/build-docker.yml/badge.svg)](https://github.com/fauteck/newsku/actions/workflows/build-docker.yml)
[![License](https://img.shields.io/github/license/fauteck/newsku)](LICENSE)
[![Image](https://ghcr.io/fauteck/newsku)](https://github.com/fauteck/newsku/pkgs/container/newsku)

Selbst-gehosteter RSS-Reader, der LLMs (OpenAI) nutzt, um Feed-Beitraege nach persoenlicher Relevanz zu sortieren und zu priorisieren.

---

## Feature-Uebersicht

| Feature | Beschreibung |
|---------|-------------|
| RSS/Atom Feed-Verwaltung | Feeds hinzufuegen, kategorisieren, automatisch aktualisieren |
| KI-gesteuertes Ranking | OpenAI bewertet Beitraege nach Benutzerpraeferenzen (`importanceScore`) |
| Feed-Kategorien | Benutzerdefinierte Gruppierung von Feeds |
| Layout-Anpassung | Startseiten-Bloecke individuell konfigurieren |
| E-Mail Digest | Geplanter Versand der wichtigsten Beitraege |
| Volltextsuche | Suche ueber alle Feed-Beitraege |
| Klick-Statistiken | Engagement-Tracking pro Feed und Tag |
| Benutzerregistrierung | Steuerbar via `ALLOW_SIGNUP` (Standard: deaktiviert) |
| OIDC-Unterstuetzung | Optionale OpenID Connect Authentifizierung |
| PWA + Android App | Flutter-basierte Web-App und nativer Android-Client |

---

## Architektur

```
+--------------------+       +--------------------+
|   Flutter Web/App  |──────▶|   Spring Boot API  |
|  (Material 3, BLoC)|  HTTP |  (Java 25, Port    |
|   PWA + Android    |       |   8080)            |
+--------------------+       +----------+---------+
                                         │  JPA/JDBC
                               +---------▼---------+
                               |   PostgreSQL 18    |
                               |   (Flyway V1–V16)  |
                               +-------------------+
                                         │
                               +---------▼---------+
                               |   OpenAI API       |
                               |  (LLM Ranking)     |
                               +-------------------+
```

**Tech Stack:**

| Schicht | Technologie |
|---------|------------|
| Backend | Spring Boot 4.0.1, Java 25, Amazon Corretto |
| Datenbank | PostgreSQL 18, Flyway Migrationen (V1–V16) |
| Frontend | Flutter ^3.10.0, Material Design 3, BLoC |
| LLM | OpenAI Java SDK 4.13.0 |
| RSS Parsing | Apptastic RSS Reader 3.12.0 |
| Auth | JWT (JJWT 0.13.0) + optionales OIDC |
| E-Mail | Simple Java Mail 6.6.1, Freemarker Templates |
| Container | Docker, GHCR Registry |

---

## Voraussetzungen

| Anforderung | Version |
|-------------|---------|
| Docker + Docker Compose | 24+ |
| PostgreSQL | 18 (oder via Docker) |
| OpenAI API Key | — |

Fuer lokale Entwicklung zusaetzlich:

| Tool | Version |
|------|---------|
| JDK (Amazon Corretto) | 25 |
| Maven | 3.9+ |
| Flutter SDK | ^3.10.0 |

---

## Installation / Schnellstart

### 1. Repository klonen

```bash
git clone git@github.com:fauteck/newsku.git
cd newsku
```

### 2. Umgebungsvariablen konfigurieren

```bash
cp .env.example .env
# .env bearbeiten: DB-Zugangsdaten, OpenAI API-Key und SALT eintragen
```

### 3. Docker-Stack starten

```bash
docker compose up -d
```

Die Anwendung ist erreichbar unter: `http://localhost:8080`

> Hinweis: Bei `ALLOW_SIGNUP=0` (Standard) muessen Benutzer manuell in der Datenbank angelegt werden.
> Benutzerregistrierung aktivieren: `ALLOW_SIGNUP=1` in `.env` setzen.

---

## Konfiguration

### Umgebungsvariablen

| Variable | Pflicht | Standard | Beschreibung |
|----------|---------|----------|-------------|
| `DB_HOST` | Ja | `localhost` | PostgreSQL Hostname |
| `DB_PORT` | Ja | `5432` | PostgreSQL Port |
| `DB_DATABASE` | Ja | — | Datenbankname |
| `DB_USER` | Ja | — | Datenbankbenutzer |
| `DB_PASSWORD` | Ja | — | Datenbankpasswort |
| `OPENAI_API_KEY` | Ja | — | API-Key fuer LLM-Ranking |
| `OPENAI_MODEL` | Ja | — | Modellname (z. B. `gpt-4o`, `gpt-4-turbo`) |
| `OPENAI_URL` | Nein | OpenAI Standard | Eigener API-Endpunkt (Ollama, Azure, etc.) |
| `SALT` | Ja | — | Passwort-Hashing Salt (min. 32 Zeichen) |
| `ALLOW_SIGNUP` | Nein | `0` | `1` = Registrierung erlaubt |
| `TZ` | Nein | `Europe/Berlin` | Zeitzone |

### PostgreSQL-Variablen (docker-compose)

| Variable | Beschreibung |
|----------|-------------|
| `POSTGRES_DB` | Datenbankname (identisch mit `DB_DATABASE`) |
| `POSTGRES_USER` | Benutzer (identisch mit `DB_USER`) |
| `POSTGRES_PASSWORD` | Passwort (identisch mit `DB_PASSWORD`) |

---

## API-Referenz

Swagger UI erreichbar unter: `http://localhost:8080/swagger-ui.html`

### Wichtige Endpunkte

| Methode | Pfad | Beschreibung |
|---------|------|-------------|
| `POST` | `/api/users/login` | Login → JWT Token |
| `POST` | `/api/signup` | Benutzer registrieren (wenn erlaubt) |
| `GET` | `/api/feeds` | Alle Feeds des Benutzers |
| `POST` | `/api/feeds` | Neuen Feed hinzufuegen |
| `DELETE` | `/api/feeds/{id}` | Feed loeschen |
| `GET` | `/api/feed-items` | Feed-Beitraege (sortiert nach Score) |
| `PATCH` | `/api/feed-items/{id}` | Beitrag als gelesen markieren |
| `GET` | `/api/feed-categories` | Feed-Kategorien |
| `GET` | `/api/layouts` | Layout-Bloecke |
| `GET` | `/api/search?q=...` | Volltextsuche |
| `GET` | `/api/config` | Anwendungskonfiguration |
| `GET` | `/actuator/health` | Health Check |

Alle Endpunkte ausser `/api/users/login`, `/api/signup`, `/api/config` und `/actuator/health`
erfordern einen gueltigen JWT-Token: `Authorization: Bearer <token>`

---

## Sicherheitsaspekte

- **Keine Secrets im Code:** Alle sensiblen Werte ueber Umgebungsvariablen
- **`.env` nicht committen:** Nur `.env.example` versioniert
- **Passwort-Hashing:** BCrypt mit konfiguriertem SALT
- **JWT-Authentifizierung:** Kurzlebige Tokens, validiert bei jedem Request
- **OWASP Top 10:** Implementierung beruecksichtigt Injection, Auth, Security Misconfiguration etc.
- **Registrierung deaktivierbar:** Standard `ALLOW_SIGNUP=0` verhindert oeffentliche Anmeldung
- **robots.txt:** Sensible Pfade gesperrt, KI-Crawler blockiert

---

## Technologie-Stack

| Komponente | Technologie | Version |
|-----------|------------|---------|
| Backend | Spring Boot | 4.0.1 |
| Sprache (Backend) | Java | 25 (Amazon Corretto) |
| Datenbank | PostgreSQL | 18 |
| Migrationen | Flyway | — |
| ORM | Spring Data JPA / Hibernate | — |
| Frontend | Flutter | ^3.10.0 |
| Sprache (Frontend) | Dart | — |
| UI-Framework | Material Design 3 | — |
| State Management | flutter_bloc | — |
| LLM | OpenAI Java SDK | 4.13.0 |
| RSS Parsing | Apptastic RSS Reader | 3.12.0 |
| Auth | JJWT | 0.13.0 |
| E-Mail | Simple Java Mail | 6.6.1 |
| Container | Docker (Amazon Corretto 25) | — |
| Registry | GHCR (`ghcr.io/fauteck/newsku`) | — |

---

## Entwicklung

Vollstaendige Anleitung: [docs/entwicklung.md](docs/entwicklung.md)

```bash
# Backend starten (lokale PostgreSQL noetig)
mvn spring-boot:run

# Tests ausfuehren
mvn test

# Flutter Web starten
cd src/main/app && flutter run -d chrome

# Docker Build
mvn clean package -DskipTests
docker build -t newsku:local -f docker/Dockerfile .
```

Weitere Dokumente im [docs/](docs/) Verzeichnis:

| Dokument | Inhalt |
|----------|--------|
| [docs/architektur.md](docs/architektur.md) | Systemarchitektur, Request-Flow |
| [docs/api-patterns.md](docs/api-patterns.md) | Controller, Services, Repository-Pattern |
| [docs/frontend-patterns.md](docs/frontend-patterns.md) | Flutter BLoC, Routing, Widgets |
| [docs/datenbank.md](docs/datenbank.md) | PostgreSQL-Schema, Flyway-Migrationen |
| [docs/code-konventionen.md](docs/code-konventionen.md) | Java + Dart Code-Stil |
| [docs/testing.md](docs/testing.md) | JUnit, TestContainers, Flutter-Tests |
| [docs/haeufige-aufgaben.md](docs/haeufige-aufgaben.md) | How-To-Guides |

---

## Lizenz

[Lizenz ansehen](LICENSE)
