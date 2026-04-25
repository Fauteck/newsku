# Development

← [Back to Index](../CLAUDE.md)

---

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| JDK | 25 (Amazon Corretto) | Backend runtime + build |
| Maven | 3.9+ | Build tool |
| PostgreSQL | 18 | Database |
| Flutter SDK | ^3.10.0 | Frontend build |
| Docker | 24+ | Local container development |
| Python | 3.10+ | MkDocs documentation (optional) |

### Nix Shell (recommended)

The repository includes a `shell.nix` with JDK 25, Maven, and Python:

```bash
nix-shell   # provides JDK 25 + Maven + Python
```

---

## Installation

```bash
# Clone repository
git clone git@github.com:fauteck/newsku.git
cd newsku

# Create .env file
cp .env.example .env
# Set required fields:
#   DB_HOST, DB_PORT, DB_DATABASE, DB_USER, DB_PASSWORD
#   OPENAI_API_KEY, OPENAI_MODEL
#   SALT  (min. 32 characters random string)
```

---

## Start Backend (Spring Boot)

### Option A: With local PostgreSQL instance

```bash
# Set environment variables (or load from .env with source)
export DB_HOST=localhost
export DB_PORT=5432
export DB_DATABASE=newsku
export DB_USER=newsku
export DB_PASSWORD=secret
export OPENAI_API_KEY=sk-...
export OPENAI_MODEL=gpt-4o
export SALT=my-random-salt-at-least-32-characters

# Build JAR
mvn clean package -DskipTests

# Start
java -jar target/newsku-*.jar
```

Server runs at `http://localhost:8080`
Swagger UI: `http://localhost:8080/swagger-ui.html`

### Option B: PostgreSQL via Docker, backend local

```bash
# Start only the database
docker run -d \
  --name newsku_postgres \
  -e POSTGRES_DB=newsku \
  -e POSTGRES_USER=newsku \
  -e POSTGRES_PASSWORD=secret \
  -p 5432:5432 \
  postgres:18-alpine

# Start backend as in Option A
```

---

## Database Migrations

Flyway runs **automatically on startup** and executes all pending migrations.
No manual execution needed.

Create new migration:

```bash
# Choose next version number (currently: V16)
touch src/main/resources/db/migration/V17__my_change.sql
```

```sql
-- V17__my_change.sql
ALTER TABLE users ADD COLUMN language VARCHAR(10) DEFAULT 'en';
```

---

## Start Frontend (Flutter)

```bash
cd src/main/app

# Install Flutter dependencies
flutter pub get

# Code generation (routing, after changes to router.dart)
flutter pub run build_runner build --delete-conflicting-outputs

# Web dev server (points to http://localhost:8080 as backend)
flutter run -d chrome

# Or: web build for production (output: build/web/)
flutter build web
```

The web build is then served by the Spring Boot backend.
For production: copy `build/web/` to `src/main/resources/static/`, then `mvn package`.

---

## Docker-Based Development

```bash
# .env file required (or set variables directly)
cp .env.example .env

# Build JAR (copied into Docker image)
mvn clean package -DskipTests

# Start all services (app + PostgreSQL)
docker compose up -d

# View logs
docker compose logs -f newsku

# Stop services
docker compose down
```

---

## Maven Build

| Command | Description |
|---------|-------------|
| `mvn clean package` | Build JAR (including tests) |
| `mvn clean package -DskipTests` | Build JAR (skip tests) |
| `mvn test` | Run tests only |
| `mvn spring-boot:run` | Start backend directly (without JAR) |
| `mvn dependency:tree` | Show dependency tree |

---

## Environment Variables

Full list in `.env.example`:

| Variable | Required | Description |
|----------|---------|-------------|
| `DB_HOST` | Yes | PostgreSQL hostname |
| `DB_PORT` | Yes | PostgreSQL port (default: 5432) |
| `DB_DATABASE` | Yes | Database name |
| `DB_USER` | Yes | Database user |
| `DB_PASSWORD` | Yes | Database password |
| `OPENAI_API_KEY` | No* | Global API key (fallback when no per-user key is set) |
| `OPENAI_MODEL` | No | Default model (e.g. `gpt-4o-mini`) |
| `OPENAI_URL` | No | Default API endpoint (default: `https://api.openai.com/v1`) |
| `SALT` | Yes | Password hashing salt (min. 32 characters) |
| `APP_ENCRYPTION_KEY` | **Yes** | Base64 AES key for encrypted credential columns. Generate: `openssl rand -base64 32`. Startup aborts without this key. Do not change after initial deployment. |
| `ALLOW_SIGNUP` | No | `0` = disabled (default), `1` = active |
| `TZ` | No | Timezone (default: `Europe/Berlin`) |

\* Users can store their own keys in the AI tab; these take precedence over `OPENAI_API_KEY`.

---

## Build Documentation (MkDocs)

```bash
# Set up Python environment (or via nix-shell)
python -m venv .venv
source .venv/bin/activate
pip install -r mkdocs/requirements.txt

# Preview
cd mkdocs && mkdocs serve

# Build
make docs-build
# Output: docs/documentation/
```

---

## Feature Walkthrough: "New Field on FeedItem"

Example: add field `estimated_read_time` (reading time in seconds).

### 1. Create Flyway Migration

```sql
-- src/main/resources/db/migration/V17__add_read_time.sql
ALTER TABLE feed_items ADD COLUMN estimated_read_time INTEGER;
```

### 2. Extend JPA Entity

```java
// src/main/java/com/github/lamarios/newsku/persistence/entities/FeedItem.java
private Integer estimatedReadTime;
```

### 3. Add Service Logic

```java
// FeedItemService.java or FeedService.java
// Calculate and set field when parsing RSS content
feedItem.setEstimatedReadTime(calculateReadTime(content));
```

### 4. Update Flutter Model

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

### 5. Display in UI

```dart
// In the feed item view
if (item.estimatedReadTime != null)
  Text('Read time: ~${item.estimatedReadTime}s'),
```

---

## Debugging

- **Backend logs:** Spring Boot Logback → console (level INFO, configurable in `application.yml`)
- **Flyway debug:** Enabled in `application.yml` (`logging.level.org.flywaydb: DEBUG`)
- **DB queries:** Uncomment in `application.yml`: `jpa.show-sql: true`
- **Swagger UI:** `http://localhost:8080/swagger-ui.html` for API exploration
- **Flutter:** Browser DevTools + `flutter logs`

---

## Related Documents

- [README.md](../README.md) — Quick-start installation guide
- [docs/datenbank.md](datenbank.md) — Schema details, migrations workflow
- [docs/testing.md](testing.md) — Running tests
