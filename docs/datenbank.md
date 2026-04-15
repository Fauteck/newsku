# Datenbank

← [Zurueck zum Index](../CLAUDE.md)

---

## Uebersicht

- **Datenbank:** SQLite (via `better-sqlite3`)
- **ORM:** Drizzle ORM (TypeScript-first, synchrone Queries)
- **Schema-Datei:** `apps/api/src/db/schema.ts`
- **Migrationen:** `apps/api/drizzle/` (generiert via `drizzle-kit`)
- **Legacy-Migrationen:** `apps/api/src/db/migrate.ts` (idempotente ALTER TABLE Statements)
- **DB-Pfad:** `DATABASE_PATH` Umgebungsvariable (Standard: `/data/familytodo.db`)

---

## Tabellen-Uebersicht

| Tabelle | Beschreibung | Primaerschluessel |
|---------|-------------|-------------------|
| `users` | Benutzerkonten | `id` (UUID) |
| `projects` | Projekte / Aufgabengruppen | `id` (UUID) |
| `project_members` | Projekt-Mitgliedschaften (m:n) | `project_id` + `user_id` |
| `tasks` | Aufgaben UND Notizen (via `type`) | `id` (UUID) |
| `labels` | Farbige Labels | `id` (UUID) |
| `task_labels` | Aufgabe-Label-Zuordnung (m:n) | `task_id` + `label_id` |
| `comments` | Kommentare an Aufgaben | `id` (UUID) |
| `activity_log` | Aenderungsprotokoll | `id` (UUID) |
| `refresh_tokens` | JWT Refresh Tokens | `id` (UUID) |
| `filters` | Benutzerdefinierte Filter | `id` (UUID) |
| `google_keep_accounts` | Google-Keep-Verbindungen | `id` (UUID) |
| `google_keep_sync_mappings` | Keep-Notiz-Zuordnungen | `id` (UUID) |
| `google_keep_sync_snapshots` | Sync-Snapshots (Diff-Erkennung) | `id` (UUID) |
| `google_keep_todo_config` | Keep-Listen → Projekt-Zuordnung | `id` (UUID) |

---

## Schema-Details

### `users`

```typescript
// apps/api/src/db/schema.ts
export const users = sqliteTable('users', {
  id: text('id').primaryKey(),                    // UUID
  email: text('email').unique().notNull(),         // Login-Name (z.B. "niklas")
  password_hash: text('password_hash').notNull(),  // bcrypt Hash
  display_name: text('display_name').notNull(),
  avatar_color: text('avatar_color'),              // Hex-Farbe fuer Avatar
  ics_token: text('ics_token').unique(),           // Klartext (wird nach Migration geloescht)
  ics_token_hash: text('ics_token_hash').unique(), // SHA-256 Hash fuer iCal-Auth
  ics_token_rotated_at: text('ics_token_rotated_at'),
  public_api_token_hash: text('public_api_token_hash').unique(), // SHA-256 Hash fuer Public API
  public_api_token_rotated_at: text('public_api_token_rotated_at'),
  activity_last_read_at: text('activity_last_read_at'),
  created_at: text('created_at').notNull(),        // ISO 8601 String
});
```

### `projects`

```typescript
export const projects = sqliteTable('projects', {
  id: text('id').primaryKey(),
  owner_id: text('owner_id').notNull().references(() => users.id),
  name: text('name').notNull(),
  color: text('color'),                            // Hex-Farbe
  icon: text('icon'),                              // Icon-Name
  is_shared: integer('is_shared').notNull().default(0), // 1 = Familien-Projekt
  sort_order: integer('sort_order'),
  archived_at: text('archived_at'),                // null = aktiv
  external_id: text('external_id'),                // Fuer externe Sync
  created_at: text('created_at').notNull(),
});
```

### `project_members`

```typescript
export const project_members = sqliteTable('project_members', {
  project_id: text('project_id').notNull().references(() => projects.id),
  user_id: text('user_id').notNull().references(() => users.id),
  role: text('role', { enum: ['owner', 'editor', 'viewer'] }).notNull(),
  added_at: text('added_at').notNull(),
});
```

### `tasks`

Speichert sowohl **Aufgaben** (`type: 'todo'`) als auch **Notizen** (`type: 'note'`):

```typescript
export const tasks = sqliteTable('tasks', {
  id: text('id').primaryKey(),
  project_id: text('project_id').notNull().references(() => projects.id),
  creator_id: text('creator_id').notNull().references(() => users.id),
  assignee_id: text('assignee_id').references(() => users.id),
  parent_task_id: text('parent_task_id'),          // Unteraufgaben (self-ref)
  title: text('title').notNull(),
  description: text('description'),                // Plain-Text oder Tiptap JSON
  due_date: text('due_date'),                      // Format: YYYY-MM-DD
  due_time: text('due_time'),                      // Format: HH:MM
  priority: integer('priority').notNull().default(4), // 1=dringend, 2=hoch, 3=normal, 4=keine
  status: text('status', { enum: ['open', 'done', 'archived'] }).notNull().default('open'),
  completed_at: text('completed_at'),
  recurrence_rule: text('recurrence_rule'),         // z.B. "daily", "weekly:mon,wed"
  recurrence_next: text('recurrence_next'),         // Naechstes Faelligkeitsdatum
  sort_order: integer('sort_order'),
  type: text('type', { enum: ['todo', 'note'] }).notNull().default('todo'),
  content_format: text('content_format', { enum: ['plain', 'tiptap_json'] }).notNull().default('plain'),
  canvas_data: text('canvas_data'),                 // Optionale Excalidraw-Skizze (JSON), unabhaengig von description
  show_in_menu: integer('show_in_menu').notNull().default(0), // Notiz im Seitenmenue anpinnen
  numeric_id: integer('numeric_id'),               // Auto-Increment fuer Notizen
  external_id: text('external_id'),
  created_at: text('created_at').notNull(),
  updated_at: text('updated_at').notNull(),
});
```

### `labels` + `task_labels`

```typescript
export const labels = sqliteTable('labels', {
  id: text('id').primaryKey(),
  user_id: text('user_id').notNull().references(() => users.id),
  project_id: text('project_id').references(() => projects.id), // Optional: Projekt-spezifisch
  name: text('name').notNull(),
  color: text('color').notNull(),
  created_at: text('created_at').notNull(),
});

export const task_labels = sqliteTable('task_labels', {
  task_id: text('task_id').notNull().references(() => tasks.id),
  label_id: text('label_id').notNull().references(() => labels.id),
});
```

### `comments`

```typescript
export const comments = sqliteTable('comments', {
  id: text('id').primaryKey(),
  task_id: text('task_id').notNull().references(() => tasks.id),
  author_id: text('author_id').notNull().references(() => users.id),
  body: text('body').notNull(),
  created_at: text('created_at').notNull(),
  updated_at: text('updated_at').notNull(),
});
```

### `activity_log`

```typescript
export const activity_log = sqliteTable('activity_log', {
  id: text('id').primaryKey(),
  task_id: text('task_id').references(() => tasks.id),
  project_id: text('project_id').references(() => projects.id),
  user_id: text('user_id').notNull().references(() => users.id),
  action: text('action').notNull(),   // z.B. "task.created", "task.completed"
  meta: text('meta'),                 // JSON-String mit Zusatzinfos
  created_at: text('created_at').notNull(),
});
```

### `refresh_tokens`

```typescript
export const refresh_tokens = sqliteTable('refresh_tokens', {
  id: text('id').primaryKey(),
  user_id: text('user_id').notNull().references(() => users.id),
  token_hash: text('token_hash').notNull(),
  device_name: text('device_name'),
  user_agent: text('user_agent'),
  expires_at: text('expires_at').notNull(),
  created_at: text('created_at').notNull(),
  last_used_at: text('last_used_at').notNull(),
});
```

### `filters`

```typescript
export const filters = sqliteTable('filters', {
  id: text('id').primaryKey(),
  user_id: text('user_id').notNull().references(() => users.id),
  name: text('name').notNull(),
  color: text('color').notNull().default('#6366f1'),
  show_in_menu: integer('show_in_menu').notNull().default(0),
  project_ids: text('project_ids'),       // Komma-separierte UUIDs
  date_from: text('date_from'),
  date_to: text('date_to'),
  item_type: text('item_type', { enum: ['todo', 'note', 'both'] }).notNull().default('both'),
  text_search: text('text_search'),
  label_ids: text('label_ids'),           // Komma-separierte UUIDs
  priorities: text('priorities'),          // Komma-separierte Zahlen
  created_at: text('created_at').notNull(),
  updated_at: text('updated_at').notNull(),
});
```

---

## Beziehungen (ER-Diagramm)

```
users ──1:n──▶ projects (owner_id)
users ──m:n──▶ projects (via project_members)
projects ──1:n──▶ tasks (project_id)
users ──1:n──▶ tasks (creator_id, assignee_id)
tasks ──1:n──▶ tasks (parent_task_id → self-referencing)
tasks ──m:n──▶ labels (via task_labels)
tasks ──1:n──▶ comments (task_id)
users ──1:n──▶ comments (author_id)
users ──1:n──▶ activity_log (user_id)
users ──1:n──▶ refresh_tokens (user_id)
users ──1:n──▶ filters (user_id)
users ──1:n──▶ labels (user_id)
users ──1:n──▶ google_keep_accounts (user_id)
```

---

## Migrationen

### Drizzle-Kit Migrationen

```bash
# Neue Migration generieren (nach Schema-Aenderung)
cd apps/api
npx drizzle-kit generate

# Migrationen ausfuehren
npm run db:migrate
```

Generierte SQL-Dateien liegen in `apps/api/drizzle/`.

### Legacy-Migrationen

In `apps/api/src/db/migrate.ts` (`runLegacyMigrations()`) befinden sich idempotente ALTER TABLE Statements fuer Abwaertskompatibilitaet mit bestehenden Datenbanken. Diese laufen bei jedem Start automatisch.

### Canvas-Refactor (Aufgaben/Notizen mit optionaler Skizze)

Bis zum Refactor war eine Excalidraw-Zeichnung ein Subtyp einer Notiz: `content_format='excalidraw_json'` und der JSON lag im `description`-Feld. Nach dem Refactor ist eine Zeichnung eine **optionale Ergaenzung** jeder Aufgabe und Notiz, gespeichert im neuen Feld `tasks.canvas_data`.

- Spalte `canvas_data TEXT` (nullable) wird per Legacy-Migration angefuegt.
- Bestehende Canvas-Notizen werden migriert: `canvas_data := description`, `description := NULL`, `content_format := 'tiptap_json'`. `type` bleibt `note`.
- Listen-Endpoints liefern statt des potenziell grossen `canvas_data`-Felds das leichtgewichtige Bool `has_canvas`. Detail-Endpoints (`GET /tasks/:id`) liefern das vollstaendige `canvas_data`.

---

## SQLite-Hinweise

- **Datumsformat:** Alle Datum/Zeit-Spalten sind `TEXT` im ISO-8601-Format
- **Boolean:** SQLite kennt kein BOOLEAN → `INTEGER` mit 0/1
- **UUIDs:** Alle Primaerschluessel sind `TEXT` mit UUIDv4 (generiert via `uuid` Package)
- **Foreign Keys:** Aktiviert via `PRAGMA foreign_keys = ON`
- **Backup:** Automatisch via Docker-Container (`backup` Service), 30 Tage Retention

---

## Verwandte Dokumente

- [docs/api-patterns.md](api-patterns.md) — Wie Services auf die DB zugreifen
- [docs/haeufige-aufgaben.md](haeufige-aufgaben.md) — Neue Tabelle/Spalte hinzufuegen
