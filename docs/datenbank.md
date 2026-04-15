# Datenbank

← [Zurueck zum Index](../CLAUDE.md)

---

## Uebersicht

- **Datenbank:** PostgreSQL 18
- **ORM:** Spring Data JPA (Hibernate)
- **Schema-Verwaltung:** Flyway (automatisch beim Start)
- **Migrationen:** `src/main/resources/db/migration/V*.sql` (V1–V16)
- **Konfiguration:** `src/main/resources/application.yml`

Flyway fuehrt beim Anwendungsstart automatisch alle ausstehenden Migrationen aus.
Der Verbindungsstring wird aus Umgebungsvariablen gebildet:
```
jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_DATABASE}
```

---

## Tabellen-Uebersicht

| Tabelle | Beschreibung | Primaerschluessel |
|---------|-------------|-------------------|
| `users` | Benutzerkonten | `id` (UUID/String) |
| `feeds` | RSS-Feed-Abonnements | `id` |
| `feed_items` | Einzelne RSS-Beitraege | `id` |
| `feed_categories` | Benutzerdefinierte Kategorien | `id` |
| `feed_errors` | Fehlerprotokoll beim Feed-Abruf | `id` |
| `layout_blocks` | Konfigurierbare UI-Bloecke | `id` |
| `feed_clicks` / `click_stats` / `tag_clicks` | Klick-Statistiken | `id` |
| `user_settings` | Benutzereinstellungen | `user_id` |

---

## JPA Entities (Schluessel-Entities)

### `User` (`users`)

```java
// src/main/java/com/github/lamarios/newsku/persistence/entities/User.java
@Entity
@Table(name = "users")
public class User {
    @Id
    private String id;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String password;      // BCrypt-Hash

    private String settings;      // JSON: Benutzereinstellungen
    private String oidcSub;       // OIDC Subject (optional)
    // ...
}
```

### `Feed` (`feeds`)

```java
@Entity
@Table(name = "feeds")
public class Feed {
    @Id
    private String id;

    @Column(nullable = false)
    private String userId;

    @Column(nullable = false)
    private String feedUrl;

    private String title;
    private String description;
    private String categoryId;    // Referenz auf feed_categories
    private Instant lastFetched;
    // ...
}
```

### `FeedItem` (`feed_items`)

```java
@Entity
@Table(name = "feed_items")
public class FeedItem {
    @Id
    private String id;

    @Column(nullable = false)
    private String feedId;

    private String title;
    private String content;
    private String url;
    private String imageUrl;
    private String[] tags;
    private Instant publishedAt;
    private boolean read;
    private Double importanceScore;   // LLM-Bewertung (0.0 – 1.0)
    // ...
}
```

### `FeedCategory` (`feed_categories`)

```java
@Entity
@Table(name = "feed_categories")
public class FeedCategory {
    @Id
    private String id;

    @Column(nullable = false)
    private String userId;

    @Column(nullable = false)
    private String name;
    // ...
}
```

### `LayoutBlock` (`layout_blocks`)

```java
@Entity
@Table(name = "layout_blocks")
public class LayoutBlock {
    @Id
    private String id;

    @Column(nullable = false)
    private String userId;

    private String blockType;    // z. B. "feed", "category", "all"
    private String settings;     // JSON: Block-spezifische Einstellungen
    private Integer sortOrder;
    // ...
}
```

---

## Beziehungen (ER-Diagramm)

```
users ──1:n──▶ feeds (userId)
feeds ──1:n──▶ feed_items (feedId)
users ──1:n──▶ feed_categories (userId)
feeds ──n:1──▶ feed_categories (categoryId)
feeds ──1:n──▶ feed_errors (feedId)
users ──1:n──▶ layout_blocks (userId)
users ──1:1──▶ user_settings (userId)
feed_items ──1:n──▶ feed_clicks (itemId)
```

---

## Flyway-Migrationen

### Migration-Konvention

Migrationsdateien liegen in `src/main/resources/db/migration/` und folgen dem Muster:

```
V{version}__{beschreibung}.sql
```

**Wichtig:** Versionsnummer muss eindeutig und aufsteigend sein. Bestehende Migrationen
duerfen nach dem ersten Ausrollen **niemals** veraendert werden.

### Vorhandene Migrationen (V1–V16)

| Version | Beschreibung |
|---------|-------------|
| V1 | Initiales Schema (users, feeds, feed_items, layout_blocks) |
| V2 | OIDC-Support (oidc_sub Spalte) |
| V3 | Feed-Fehlerprotokoll (feed_errors) |
| V4 | Benutzerpraeferenzen (user_settings) |
| V5 | Volltextsuche (search-Index / Hilfstabelle) |
| V6 | Klick-Tracking Tabellen (feed_clicks) |
| V7 | Gelesen-Status Tracking |
| V8 | Bild-URL an feed_items |
| V9 | Tags an feed_items |
| V10–V12 | Statistische Erweiterungen |
| V13 | Tag-Klick-Statistiken (tag_clicks) |
| V14–V15 | Feed-Kategorien Grundstruktur |
| V16 | Feed-Kategorien Erweiterungen |

### Neue Migration anlegen

```bash
# Datei erstellen (naechste Versionsnummer, z. B. V17)
touch src/main/resources/db/migration/V17__beschreibung.sql
```

```sql
-- Beispiel: V17__add_user_language.sql
ALTER TABLE users ADD COLUMN language VARCHAR(10) DEFAULT 'de';
```

Flyway fuehrt die Migration automatisch beim naechsten Start aus.

---

## JPA Repository-Pattern

```java
// src/main/java/com/github/lamarios/newsku/persistence/repositories/FeedItemRepository.java

@Repository
public interface FeedItemRepository extends JpaRepository<FeedItem, String> {

    // Spring Data Query-Methoden
    List<FeedItem> findByFeedIdOrderByImportanceScoreDesc(String feedId);

    List<FeedItem> findByFeedIdAndReadFalseOrderByPublishedAtDesc(String feedId);

    @Query("SELECT fi FROM FeedItem fi WHERE fi.feedId IN :feedIds AND fi.read = false")
    List<FeedItem> findUnreadByFeedIds(@Param("feedIds") List<String> feedIds);

    // Paginiert
    Page<FeedItem> findByFeedIdOrderByPublishedAtDesc(String feedId, Pageable pageable);
}
```

---

## Umgebungsvariablen (Datenbankverbindung)

| Variable | Standard | Beschreibung |
|----------|----------|-------------|
| `DB_HOST` | `localhost` | Hostname des PostgreSQL-Servers |
| `DB_PORT` | `15432` (dev) / `5432` (prod) | PostgreSQL-Port |
| `DB_DATABASE` | `postgres` | Datenbankname |
| `DB_USER` | `postgres` | Datenbankbenutzer |
| `DB_PASSWORD` | `postgres` | Datenbankpasswort |

---

## Verwandte Dokumente

- [docs/api-patterns.md](api-patterns.md) — Wie Services auf die DB zugreifen
- [docs/haeufige-aufgaben.md](haeufige-aufgaben.md) — Neue Tabelle / Spalte hinzufuegen
- [docs/entwicklung.md](entwicklung.md) — Lokales DB-Setup
