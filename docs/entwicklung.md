# Entwicklung

← [Zurueck zum Index](../CLAUDE.md)

---

## Voraussetzungen

| Tool | Version | Zweck |
|------|---------|-------|
| JDK | 25 (Amazon Corretto) | Backend Runtime + Build |
| Maven | 3.9+ | Build-Tool |
| PostgreSQL | 18 | Datenbank |
| Flutter SDK | ^3.10.0 | Frontend Build |
| Docker | 24+ | Lokale Container-Entwicklung |
| Python | 3.10+ | MkDocs Dokumentation (optional) |

### Nix-Shell (empfohlen)

Das Repository enthaelt eine `shell.nix` mit JDK 25, Maven und Python:

```bash
nix-shell   # Stellt JDK 25 + Maven + Python bereit
```

---

## Installation

```bash
# Repository klonen
git clone git@github.com:fauteck/newsku.git
cd newsku

# .env-Datei erstellen
cp .env.example .env
# Pflichtfelder setzen:
#   DB_HOST, DB_PORT, DB_DATABASE, DB_USER, DB_PASSWORD
#   OPENAI_API_KEY, OPENAI_MODEL
#   SALT  (min. 32 Zeichen Zufallsstring)
```

---

## Backend starten (Spring Boot)

### Option A: Mit lokaler PostgreSQL-Instanz

```bash
# Umgebungsvariablen setzen (oder in .env und mit source laden)
export DB_HOST=localhost
export DB_PORT=5432
export DB_DATABASE=newsku
export DB_USER=newsku
export DB_PASSWORD=secret
export OPENAI_API_KEY=sk-...
export OPENAI_MODEL=gpt-4o
export SALT=mein-random-salt-mindestens-32-zeichen

# JAR bauen
mvn clean package -DskipTests

# Starten
java -jar target/newsku-*.jar
```

Server laeuft auf `http://localhost:8080`
Swagger UI: `http://localhost:8080/swagger-ui.html`

### Option B: Nur PostgreSQL per Docker, Backend lokal

```bash
# Nur die Datenbank starten
docker run -d \
  --name newsku_postgres \
  -e POSTGRES_DB=newsku \
  -e POSTGRES_USER=newsku \
  -e POSTGRES_PASSWORD=secret \
  -p 5432:5432 \
  postgres:18-alpine

# Backend wie in Option A starten
```

---

## Datenbank-Migrationen

Flyway laeuft **automatisch beim Start** und fuehrt alle ausstehenden Migrationen aus.
Keine manuelle Ausfuehrung noetig.

Neue Migration anlegen:

```bash
# Naechste Versionsnummer waehlen (aktuell: V16)
touch src/main/resources/db/migration/V17__meine_aenderung.sql
```

```sql
-- V17__meine_aenderung.sql
ALTER TABLE users ADD COLUMN language VARCHAR(10) DEFAULT 'de';
```

---

## Frontend starten (Flutter)

```bash
cd src/main/app

# Flutter-Abhaengigkeiten installieren
flutter pub get

# Code-Generierung (Routing, nach Aenderungen an router.dart)
flutter pub run build_runner build --delete-conflicting-outputs

# Web Dev-Server (zeigt auf http://localhost:8080 als Backend)
flutter run -d chrome

# Oder: Web Build fuer Produktion (Ausgabe: build/web/)
flutter build web
```

Der Web Build wird dann vom Spring Boot Backend ausgeliefert.
Fuer Produktion: `build/web/` in `src/main/resources/static/` kopieren, dann `mvn package`.

---

## Docker-basierte Entwicklung

```bash
# .env-Datei benoetigt (oder Variablen direkt setzen)
cp .env.example .env

# JAR bauen (wird ins Docker Image kopiert)
mvn clean package -DskipTests

# Alle Services starten (App + PostgreSQL)
docker compose up -d

# Logs ansehen
docker compose logs -f newsku

# Services stoppen
docker compose down
```

---

## Maven Build

| Befehl | Beschreibung |
|--------|-------------|
| `mvn clean package` | JAR bauen (inkl. Tests) |
| `mvn clean package -DskipTests` | JAR bauen (Tests ueberspringen) |
| `mvn test` | Nur Tests ausfuehren |
| `mvn spring-boot:run` | Backend direkt starten (ohne JAR) |
| `mvn dependency:tree` | Abhaengigkeitsbaum anzeigen |

---

## Umgebungsvariablen

Vollstaendige Liste in `.env.example`:

| Variable | Pflicht | Beschreibung |
|----------|---------|-------------|
| `DB_HOST` | Ja | PostgreSQL Hostname |
| `DB_PORT` | Ja | PostgreSQL Port (Standard: 5432) |
| `DB_DATABASE` | Ja | Datenbankname |
| `DB_USER` | Ja | Datenbankbenutzer |
| `DB_PASSWORD` | Ja | Datenbankpasswort |
| `OPENAI_API_KEY` | Ja | API-Key fuer LLM-Ranking |
| `OPENAI_MODEL` | Ja | Modellname (z. B. `gpt-4o`) |
| `OPENAI_URL` | Nein | Eigener API-Endpunkt (Standard: OpenAI) |
| `SALT` | Ja | Passwort-Hashing Salt (min. 32 Zeichen) |
| `ALLOW_SIGNUP` | Nein | `0` = deaktiviert (Standard), `1` = aktiv |
| `TZ` | Nein | Zeitzone (Standard: `Europe/Berlin`) |

---

## Dokumentation bauen (MkDocs)

```bash
# Python-Umgebung einrichten (oder via nix-shell)
python -m venv .venv
source .venv/bin/activate
pip install -r mkdocs/requirements.txt

# Vorschau
cd mkdocs && mkdocs serve

# Build
make docs-build
# Ausgabe: docs/documentation/
```

---

## Feature-Walkthrough: "Neues Feld an FeedItem"

Beispiel: Feld `estimated_read_time` (Lesedauer in Sekunden) hinzufuegen.

### 1. Flyway-Migration erstellen

```sql
-- src/main/resources/db/migration/V17__add_read_time.sql
ALTER TABLE feed_items ADD COLUMN estimated_read_time INTEGER;
```

### 2. JPA Entity erweitern

```java
// src/main/java/com/github/lamarios/newsku/persistence/entities/FeedItem.java
private Integer estimatedReadTime;
```

### 3. Service-Logik ergaenzen

```java
// FeedItemService.java oder FeedService.java
// Feld beim Parsen des RSS-Inhalts berechnen und setzen
feedItem.setEstimatedReadTime(calculateReadTime(content));
```

### 4. Flutter-Modell aktualisieren

```dart
// lib/feed/models/feed_item.dart
class FeedItem {
  final int? estimatedReadTime;
  // ...
  factory FeedItem.fromJson(Map<String, dynamic> json) => FeedItem(
    estimatedReadTime: json['estimatedReadTime'],
    // ...
  );
}
```

### 5. UI anzeigen

```dart
// In der Feed-Item-Ansicht
if (item.estimatedReadTime != null)
  Text('Lesezeit: ~${item.estimatedReadTime}s'),
```

---

## Debugging

- **Backend-Logs:** Spring Boot Logback → Konsole (Level INFO, in `application.yml` konfigurierbar)
- **Flyway-Debug:** In `application.yml` aktiviert (`logging.level.org.flywaydb: DEBUG`)
- **DB-Queries:** In `application.yml` auskommentiert: `jpa.show-sql: true` einkommentieren
- **Swagger UI:** `http://localhost:8080/swagger-ui.html` fuer API-Exploration
- **Flutter:** Browser DevTools + `flutter logs`

---

## Verwandte Dokumente

- [README.md](../README.md) — Installations-Kurzanleitung
- [docs/datenbank.md](datenbank.md) — Schema-Details, Migrations-Workflow
- [docs/testing.md](testing.md) — Test-Ausfuehrung
