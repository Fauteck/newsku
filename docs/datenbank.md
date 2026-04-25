# Database

← [Back to Index](../CLAUDE.md)

---

## Overview

- **Database:** PostgreSQL 18
- **ORM:** Spring Data JPA (Hibernate)
- **Schema management:** Flyway (automatically on startup)
- **Migrations:** `src/main/resources/db/migration/V*.sql` (V1–V16)
- **Configuration:** `src/main/resources/application.yml`

Flyway automatically runs all pending migrations on application startup.
The connection string is built from environment variables:
```
jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_DATABASE}
```

---

## Table Overview

| Table | Description | Primary Key |
|-------|-------------|-------------|
| `users` | User accounts | `id` (UUID/String) |
| `feeds` | RSS feed subscriptions | `id` |
| `feed_items` | Individual RSS articles | `id` |
| `feed_categories` | User-defined categories | `id` |
| `feed_errors` | Feed fetch error log | `id` |
| `layout_blocks` | Configurable UI blocks | `id` |
| `feed_clicks` / `click_stats` / `tag_clicks` | Click statistics | `id` |
| `user_settings` | User settings | `user_id` |

---

## JPA Entities (Key Entities)

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
    private String password;      // BCrypt hash

    private String settings;      // JSON: user settings
    private String oidcSub;       // OIDC subject (optional)
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
    private String categoryId;    // reference to feed_categories
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
    private Double importanceScore;   // LLM score (0.0 – 1.0)
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

    private String blockType;    // e.g. "feed", "category", "all"
    private String settings;     // JSON: block-specific settings
    private Integer sortOrder;
    // ...
}
```

---

## Relationships (ER Diagram)

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

## Flyway Migrations

### Migration Convention

Migration files are in `src/main/resources/db/migration/` and follow the pattern:

```
V{version}__{description}.sql
```

**Important:** Version numbers must be unique and ascending. Existing migrations
**must never** be modified after they have been deployed.

### Existing Migrations (V1–V16)

| Version | Description |
|---------|-------------|
| V1 | Initial schema (users, feeds, feed_items, layout_blocks) |
| V2 | OIDC support (oidc_sub column) |
| V3 | Feed error log (feed_errors) |
| V4 | User preferences (user_settings) |
| V5 | Full-text search (search index / helper table) |
| V6 | Click tracking tables (feed_clicks) |
| V7 | Read status tracking |
| V8 | Image URL on feed_items |
| V9 | Tags on feed_items |
| V10–V12 | Statistical extensions |
| V13 | Tag click statistics (tag_clicks) |
| V14–V15 | Feed category base structure |
| V16 | Feed category extensions |

### Create New Migration

```bash
# Create file (next version number, e.g. V17)
touch src/main/resources/db/migration/V17__description.sql
```

```sql
-- Example: V17__add_user_language.sql
ALTER TABLE users ADD COLUMN language VARCHAR(10) DEFAULT 'en';
```

Flyway runs the migration automatically on next startup.

---

## JPA Repository Pattern

```java
// src/main/java/com/github/lamarios/newsku/persistence/repositories/FeedItemRepository.java

@Repository
public interface FeedItemRepository extends JpaRepository<FeedItem, String> {

    // Spring Data query methods
    List<FeedItem> findByFeedIdOrderByImportanceScoreDesc(String feedId);

    List<FeedItem> findByFeedIdAndReadFalseOrderByPublishedAtDesc(String feedId);

    @Query("SELECT fi FROM FeedItem fi WHERE fi.feedId IN :feedIds AND fi.read = false")
    List<FeedItem> findUnreadByFeedIds(@Param("feedIds") List<String> feedIds);

    // Paginated
    Page<FeedItem> findByFeedIdOrderByPublishedAtDesc(String feedId, Pageable pageable);
}
```

---

## Environment Variables (Database Connection)

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_HOST` | `localhost` | PostgreSQL server hostname |
| `DB_PORT` | `15432` (dev) / `5432` (prod) | PostgreSQL port |
| `DB_DATABASE` | `postgres` | Database name |
| `DB_USER` | `postgres` | Database user |
| `DB_PASSWORD` | `postgres` | Database password |
| `APP_ENCRYPTION_KEY` | — (required) | Base64 AES key (16/24/32 bytes) for field encryption at rest. Startup aborts if missing. Generate: `openssl rand -base64 32`. |

---

## Encrypted Fields

Fields containing credentials are transparently encrypted with AES-GCM via
the JPA `AttributeConverter` `StringCryptoConverter`.

| Column | Table | Encrypted | Notes |
|--------|-------|-----------|-------|
| `password` | `users` | No — BCrypt hash (login) | One-way hash, no decryption |
| `freshrss_api_password` | `users` | **Yes (AES-GCM)** | Plaintext in code, ciphertext in DB |
| `openai_api_key` | `users` | **Yes (AES-GCM)** | Per-user key (optional) |

Each ciphertext has the prefix `enc:v1:` followed by `Base64(iv || ciphertext || tag)`.
Existing plaintext rows are passed through transparently on read and automatically
encrypted on next write.

---

## OpenAI Usage Tracking (from V25)

```
users (1) ──< (n) openai_usage
```

- `openai_usage.use_case` ∈ {`RELEVANCE`, `SHORTENING`}
- `openai_usage.total_tokens` is summed per month against
  `users.openai_monthly_token_limit_relevance` and
  `users.openai_monthly_token_limit_shortening`.
- When the monthly sum exceeds the limit, `OpenaiServiceImpl` skips
  further calls for that use case until the month resets (UTC).

---

## Related Documents

- [docs/api-patterns.md](api-patterns.md) — How services access the DB
- [docs/haeufige-aufgaben.md](haeufige-aufgaben.md) — Add new table / column
- [docs/entwicklung.md](entwicklung.md) — Local DB setup
