# Newsku — fauteck Fork

[![Build](https://github.com/fauteck/newsku/actions/workflows/build-docker.yml/badge.svg)](https://github.com/fauteck/newsku/actions/workflows/build-docker.yml)
[![License](https://img.shields.io/github/license/fauteck/newsku)](LICENSE)
[![Image](https://ghcr.io/fauteck/newsku)](https://github.com/fauteck/newsku/pkgs/container/newsku)

> **Fork von [lamarios/newsku](https://github.com/lamarios/newsku)**  
> Dieses Repository ist ein Fork des ursprünglichen Projekts von [@lamarios](https://github.com/lamarios).
> Fauteck hat newsku eigenständig weiterentwickelt und um GReader-Integration, App-Verbesserungen
> sowie Docker-Setup-Anpassungen ergänzt.

---

> [!WARNING]
> **Vibecoding-Disclaimer**
>
> Dieses Repository wurde mit KI-gestütztem Coding (Vibecoding) weiterentwickelt. Änderungen
> entstanden mit Unterstützung von [Claude Code](https://claude.ai/code) (Anthropic). Obwohl
> Qualität und Sicherheit angestrebt wurden, kann KI-generierter Code Fehler, Sicherheitslücken
> oder unerwartetes Verhalten enthalten. **Verwendung auf eigene Gefahr.** Kritische Abschnitte
> vor dem Produktionseinsatz manuell prüfen und testen.
>
> *This repository was developed with AI-assisted coding (vibe coding). AI-generated code may
> contain bugs, security vulnerabilities, or unintended behavior. Use at your own risk.*

---

Selbst-gehosteter RSS-Reader, der LLMs (OpenAI) nutzt, um Feed-Beiträge nach persönlicher
Relevanz zu sortieren und zu priorisieren. Optionale GReader-Integration macht newsku zu einer
reinen Darstellungs- und KI-Scoring-Schicht über die GReader-API.

---

## Was fauteck hinzugefügt hat

| Erweiterung | Beschreibung |
|-------------|-------------|
| **GReader-Integration** | newsku als Präsentationsschicht über die GReader-API: Feeds, Kategorien und Artikel werden über die Google Reader API aus GReader synchronisiert. Lesestatus wird zurück an GReader gemeldet. |
| **"In GReader öffnen"-Button** | Direktlink zur GReader-Oberfläche aus der App heraus (konfigurierbar via `GREADER_URL`) |
| **GReader-Zugangsdaten in den Einstellungen** | Benutzer können GReader-Benutzernamen und API-Passwort direkt in der App hinterlegen |
| **Gespeicherte Artikel** | Artikel können für später gespeichert/gemerkt werden |
| **App-Verbesserungen** | Wischgesten, Tastaturkürzel, Textkürzel-Einstellungen, Insights-Widget, Zurück-Button in Desktop-Einstellungen, scrollbare Darstellungsseite |
| **App-Branding** | Browser-Tab-Titel, PWA-Name und Manifest auf „Feedteck" umgestellt |
| **Docker-Setup** | Angepasste Docker-Konfiguration und Deployment-Einrichtung |

---

## Feature-Übersicht

| Feature | Beschreibung |
|---------|-------------|
| GReader-Integration | newsku als KI-Scoring-Schicht über die GReader-API (Google Reader API) |
| RSS/Atom Feed-Verwaltung | Feeds hinzufügen, kategorisieren, automatisch aktualisieren |
| KI-gesteuertes Ranking | OpenAI bewertet Beiträge nach Benutzerpräferenzen (`importanceScore`) |
| Feed-Kategorien | Benutzerdefinierte Gruppierung von Feeds |
| Layout-Anpassung | Startseiten-Blöcke individuell konfigurieren |
| E-Mail Digest | Geplanter Versand der wichtigsten Beiträge |
| Volltextsuche | Suche über alle Feed-Beiträge |
| Klick-Statistiken | Engagement-Tracking pro Feed und Tag |
| Gespeicherte Artikel | Artikel für später markieren |
| Benutzerregistrierung | Steuerbar via `ALLOW_SIGNUP` (Standard: deaktiviert) |
| OIDC-Unterstützung | Optionale OpenID Connect Authentifizierung |
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
                               |   (Flyway V1–V18)  |
                               +-------------------+
                                         │
                               +---------▼---------+
                               |   OpenAI API       |
                               |  (LLM Ranking)     |
                               +-------------------+
                                         │
                               +---------▼---------+
                               |   GReader-API      |
                               |  (Google Reader    |
                               |   API, optional)   |
                               +-------------------+
```

**GReader-Modus:** Wenn `GREADER_URL` gesetzt ist, übernimmt GReader das RSS-Fetching,
die Feed- und Kategorienverwaltung sowie die Lesestatus-Verwaltung. newsku fügt KI-Scoring
und E-Mail-Digest hinzu. Feeds ohne GReader-Verknüpfung werden weiterhin direkt via RSS
abgerufen (Rückwärtskompatibilität).

**Tech Stack:**

| Schicht | Technologie |
|---------|------------|
| Backend | Spring Boot 4.0.1, Java 25, Amazon Corretto |
| Datenbank | PostgreSQL 18, Flyway Migrationen (V1–V18) |
| Frontend | Flutter ^3.10.0, Material Design 3, BLoC |
| LLM | OpenAI Java SDK 4.13.0 |
| RSS Parsing | Apptastic RSS Reader 3.12.0 |
| GReader-API | Google Reader API (optional) |
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
| GReader-komp. Backend | optional, jeder GReader-API-Server (z. B. GReader, Miniflux) |

Für lokale Entwicklung zusätzlich:

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
# Optional: GREADER_URL setzen wenn GReader genutzt werden soll
```

### 3. Docker-Stack starten

```bash
docker compose up -d
```

Die Anwendung ist erreichbar unter: `http://localhost:8080`

> Hinweis: Bei `ALLOW_SIGNUP=0` (Standard) müssen Benutzer manuell in der Datenbank angelegt werden.
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
| `OPENAI_API_KEY` | Nein¹ | — | Fallback-API-Key, wenn kein per-User-Key gesetzt ist |
| `OPENAI_MODEL` | Nein | `gpt-4o-mini` | Default-Modell (per Benutzer überschreibbar) |
| `OPENAI_URL` | Nein | `https://api.openai.com/v1` | Default-API-Endpunkt (Ollama, Azure, etc.) |
| `SALT` | Ja | — | Passwort-Hashing Salt (min. 32 Zeichen) |
| `APP_ENCRYPTION_KEY` | **Ja** | — | Base64-AES-Schlüssel für verschlüsselte Credential-Spalten (GReader-Passwort, OpenAI-API-Key). Generierung: `openssl rand -base64 32`. Startup bricht ohne diesen Key ab. |
| `ALLOW_SIGNUP` | Nein | `0` | `1` = Registrierung erlaubt |
| `GREADER_URL` | Nein | — | URL zur GReader-kompatibler Instanz (aktiviert GReader-Modus) |
| `TZ` | Nein | `Europe/Berlin` | Zeitzone |
| `FEED_SYNC_CRON` | Nein | `0 15,35,55 * * * *` | Spring-Cron-Expression für den Feed-Sync (direkte RSS + GReader). Default: 3×/Stunde zu Minute :15/:35/:55, abgestimmt auf die empfohlene FreshRSS-Kadenz `CRON_MIN=10,30,50` (Sync jeweils 5 Min nach FreshRSS-Fetch). Syntax: 6 Felder `sec min hour day month weekday`. |

¹ Ein Benutzer kann im KI-Tab einen eigenen API-Key hinterlegen; dieser hat Vorrang vor `OPENAI_API_KEY`.

### Sicherheit sensibler Felder

- **Login-Passwort:** BCrypt-Hash (einweg).
- **GReader-API-Passwort & OpenAI-API-Key:** Verschlüsselt at rest mit
  AES-GCM über `APP_ENCRYPTION_KEY`. Key ändern = bestehende Ciphertexte
  sind nicht mehr entschlüsselbar — Key nur einmalig zu Projektstart
  setzen und sicher verwahren.

### GReader-Konfiguration

Wenn `GREADER_URL` gesetzt ist, wird der GReader-Modus aktiviert:

1. `GREADER_URL` auf die URL der GReader-kompatibler Instanz setzen (z. B. `https://greader.example.com`)
2. In den Benutzereinstellungen der App: GReader-Benutzername und API-Passwort hinterlegen
3. newsku synchronisiert automatisch Feeds, Kategorien und Artikel aus GReader

> Das GReader API-Passwort findet sich in GReader unter:
> Einstellungen → Profil → API-Passwort (bei FreshRSS) bzw. der jeweiligen GReader-Oberfläche

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
| `POST` | `/api/feeds` | Neuen Feed hinzufügen |
| `DELETE` | `/api/feeds/{id}` | Feed löschen |
| `GET` | `/api/feed-items` | Feed-Beiträge (sortiert nach Score) |
| `PATCH` | `/api/feed-items/{id}` | Beitrag als gelesen markieren |
| `GET` | `/api/feed-categories` | Feed-Kategorien |
| `GET` | `/api/layouts` | Layout-Blöcke |
| `GET` | `/api/search?q=...` | Volltextsuche |
| `GET` | `/api/config` | Anwendungskonfiguration (inkl. `gReaderUrl`) |
| `GET` | `/api/openai/usage` | OpenAI-Token-Verbrauch des aktuellen Monats (pro Use-Case) |
| `GET` | `/actuator/health` | Health Check |

Alle Endpunkte außer `/api/users/login`, `/api/signup`, `/api/config` und `/actuator/health`
erfordern einen gültigen JWT-Token: `Authorization: Bearer <token>`

---

## Sicherheitsaspekte

- **Keine Secrets im Code:** Alle sensiblen Werte über Umgebungsvariablen
- **`.env` nicht committen:** Nur `.env.example` versioniert
- **Passwort-Hashing:** BCrypt mit konfiguriertem SALT
- **GReader API-Passwort:** Wird verschlüsselt gespeichert, nie in API-Antworten zurückgegeben
- **JWT-Authentifizierung:** Kurzlebige Tokens, validiert bei jedem Request
- **OWASP Top 10:** Implementierung berücksichtigt Injection, Auth, Security Misconfiguration etc.
- **Registrierung deaktivierbar:** Standard `ALLOW_SIGNUP=0` verhindert öffentliche Anmeldung
- **robots.txt:** Sensible Pfade gesperrt, KI-Crawler blockiert

---

## Technologie-Stack

| Komponente | Technologie | Version |
|-----------|------------|---------|
| Backend | Spring Boot | 4.0.1 |
| Sprache (Backend) | Java | 25 (Amazon Corretto) |
| Datenbank | PostgreSQL | 18 |
| Migrationen | Flyway | V1–V18 |
| ORM | Spring Data JPA / Hibernate | — |
| Frontend | Flutter | ^3.10.0 |
| Sprache (Frontend) | Dart | — |
| UI-Framework | Material Design 3 | — |
| State Management | flutter_bloc | — |
| LLM | OpenAI Java SDK | 4.13.0 |
| RSS Parsing | Apptastic RSS Reader | 3.12.0 |
| GReader-API | Google Reader API | optional |
| Auth | JJWT | 0.13.0 |
| E-Mail | Simple Java Mail | 6.6.1 |
| Container | Docker (Amazon Corretto 25) | — |
| Registry | GHCR (`ghcr.io/fauteck/newsku`) | — |

---

## Entwicklung

Vollständige Anleitung: [docs/entwicklung.md](docs/entwicklung.md)

```bash
# Backend starten (lokale PostgreSQL nötig)
mvn spring-boot:run

# Tests ausführen
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

## Ursprüngliches Projekt

Dieses Projekt basiert auf [lamarios/newsku](https://github.com/lamarios/newsku).
Vielen Dank an [@lamarios](https://github.com/lamarios) für das ursprüngliche Open-Source-Projekt.

---

## Lizenz

[Lizenz ansehen](LICENSE)
