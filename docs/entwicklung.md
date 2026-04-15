# Entwicklung

← [Zurueck zum Index](../CLAUDE.md)

---

## Voraussetzungen

| Tool | Version | Zweck |
|------|---------|-------|
| Node.js | >= 18 | Runtime |
| npm | >= 9 | Package Manager (Workspaces) |
| Python | >= 3.10 | Keep-Sync Sidecar (optional) |
| Docker | >= 24 | Lokale Container-Entwicklung (optional) |

---

## Installation

```bash
# Repository klonen
git clone git@github.com:fauteck/todo.git
cd todo

# Dependencies installieren (alle Workspaces)
npm install

# .env-Datei erstellen
cp .env.example .env
# Pflichtfelder setzen:
#   JWT_SECRET          → Starker Zufallswert (min. 32 Zeichen)
#   JWT_REFRESH_SECRET  → Starker Zufallswert (anders als JWT_SECRET)
#   SEED_PASSWORD_NIKLAS → Passwort fuer Benutzer "niklas"
#   SEED_PASSWORD_AYLIN  → Passwort fuer Benutzer "aylin"
```

---

## Dev-Server starten

```bash
# API starten (Port 3000)
npm run dev:api

# Web starten (Port 5173, Vite)
npm run dev:web

# Beide gleichzeitig (in separaten Terminals)
npm run dev:api &
npm run dev:web
```

Die Web-App proxied `/api/*` automatisch an den API-Server (Vite Proxy-Config).

---

## Datenbank

```bash
# Migrationen ausfuehren (automatisch beim API-Start)
cd apps/api
npm run db:migrate

# Neue Migration generieren (nach Schema-Aenderung in schema.ts)
npx drizzle-kit generate

# Passwort zuruecksetzen
npm run reset-password -- <email>
```

Die DB-Datei liegt standardmaessig unter dem Pfad aus `DATABASE_PATH` (`.env`).

---

## Docker-basierte Entwicklung

```bash
# Alle Services starten (API, Web, Keep-Sync, Backup)
docker compose up -d

# Logs ansehen
docker compose logs -f todo_api

# Neubauen nach Code-Aenderungen
docker compose build
docker compose up -d
```

---

## Scripts (package.json)

### Root (`/home/user/todo/package.json`)

| Script | Befehl |
|--------|--------|
| `npm run dev:api` | API Dev-Server (tsx watch) |
| `npm run dev:web` | Web Dev-Server (Vite) |
| `npm run build` | Alle Workspaces bauen (shared-types → api → web) |
| `npm run test` | Tests aller Workspaces ausfuehren |
| `npm run reset-password -- <email>` | Passwort zuruecksetzen |

### API (`apps/api/package.json`)

| Script | Befehl |
|--------|--------|
| `npm run dev` | `tsx watch src/index.ts` |
| `npm run build` | `tsc` |
| `npm run start` | `node dist/index.js` |
| `npm run db:generate` | `drizzle-kit generate` |
| `npm run db:migrate` | `tsx src/db/migrate.ts` |
| `npm run test` | `vitest run` |

### Web (`apps/web/package.json`)

| Script | Befehl |
|--------|--------|
| `npm run dev` | `vite` |
| `npm run build` | `tsc && vite build` |
| `npm run preview` | `vite preview` |
| `npm run test` | `vitest run` |

---

## Umgebungsvariablen

Vollstaendige Liste in `.env.example`:

| Variable | Pflicht | Beschreibung |
|----------|---------|-------------|
| `DATABASE_PATH` | Ja | Pfad zur SQLite-Datei |
| `JWT_SECRET` | Ja | JWT Access Token Secret |
| `JWT_REFRESH_SECRET` | Ja | JWT Refresh Token Secret |
| `JWT_ACCESS_EXPIRES` | Nein | Access Token Lebensdauer (Standard: `15m`) |
| `JWT_REFRESH_EXPIRES` | Nein | Refresh Token Lebensdauer (Standard: `90d`) |
| `CORS_ORIGIN` | Prod: Ja | Erlaubte Origins (komma-separiert) |
| `PORT` | Nein | API-Port (Standard: `3000`) |
| `SEED_PASSWORD_NIKLAS` | Erststart | Passwort fuer initialen Benutzer |
| `SEED_PASSWORD_AYLIN` | Erststart | Passwort fuer initialen Benutzer |
| `GOOGLE_TOKEN_ENCRYPTION_KEY` | Nein | 32-Byte Hex (AES-256) fuer Keep-Sync |
| `GOOGLE_CALENDAR_URLS` | Nein | Google Calendar iCal-URLs |
| `AUTHELIA_ENABLED` | Nein | SSO aktivieren (`true`/`false`) |
| `ACTIVITY_LOG_RETENTION_DAYS` | Nein | Log-Aufbewahrung (Standard: `90`) |

---

## Feature-Walkthrough: "Neues Feld an Aufgabe"

Beispiel: Feld `estimated_minutes` an Aufgaben hinzufuegen.

### 1. Schema erweitern

```typescript
// apps/api/src/db/schema.ts — in tasks Table:
estimated_minutes: integer('estimated_minutes'),
```

### 2. Migration generieren

```bash
cd apps/api
npx drizzle-kit generate
```

### 3. Shared Types aktualisieren

```typescript
// packages/shared-types/src/index.ts — in Task Interface:
estimated_minutes?: number | null;

// In UpdateTaskPayload:
estimated_minutes?: number | null;
```

### 4. Zod-Schema anpassen

```typescript
// apps/api/src/routes/tasks.ts
const updateTaskSchema = z.object({
  // ... bestehende Felder
  estimated_minutes: z.number().int().min(0).optional().nullable(),
});
```

### 5. Service anpassen (falls noetig)

```typescript
// apps/api/src/services/taskService.ts
// In buildTaskUpdates(): Feld wird automatisch via Drizzle-Update uebernommen
```

### 6. Frontend: Komponente erweitern

```typescript
// apps/web/src/components/TaskEditModal.tsx
// Neues Input-Feld hinzufuegen
```

### 7. Tests anpassen

```bash
npm run test
```

---

## Debugging

- **API-Logs:** Fastify Logger (JSON) → `fastify.log.info()`, `fastify.log.error()`
- **DB-Queries:** In Dev-Mode sind Drizzle-Queries in der Konsole sichtbar
- **Frontend:** React DevTools + Browser Network Tab
- **WebSockets:** Socket.io Debug: `DEBUG=socket.io* npm run dev:api`

---

## Verwandte Dokumente

- [README.md](../README.md) — Ausfuehrliche Setup-Anleitung, Android-APK-Build
- [docs/datenbank.md](datenbank.md) — Schema-Details, Migration-Workflow
- [docs/testing.md](testing.md) — Test-Ausfuehrung, Patterns
