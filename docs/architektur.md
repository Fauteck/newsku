# Architektur

← [Zurueck zum Index](../CLAUDE.md)

---

## Monorepo-Uebersicht

Todoteck ist ein Monorepo mit npm Workspaces, bestehend aus 3 Anwendungen und 1 Shared-Package:

```
apps/
  api/          → Fastify REST API + Socket.io (Node.js/TypeScript)
  web/          → React SPA + Android App (Vite + Tailwind + Capacitor)
  keep-sync/    → Google Keep Sync Sidecar (Python/FastAPI)
packages/
  shared-types/ → Gemeinsame TypeScript-Interfaces (API & Web)
```

---

## Tech Stack

### Backend (`apps/api/`)

| Technologie | Version | Zweck |
|-------------|---------|-------|
| Fastify | 5.x | HTTP-Server |
| Drizzle ORM | 0.30.x | TypeScript-first ORM |
| SQLite (better-sqlite3) | 12.x | Datenbank |
| Zod | 3.x | Request-Validierung |
| @fastify/jwt | 10.x | JWT-Authentifizierung |
| Socket.io | 4.x | Echtzeit-WebSockets |
| bcryptjs | 2.x | Passwort-Hashing |
| ical-generator | 8.x | Kalender-Export (.ics) |
| fastify-plugin | 5.x | Plugin-Registrierung |

### Frontend (`apps/web/`)

| Technologie | Version | Zweck |
|-------------|---------|-------|
| React | 18.x | UI-Framework |
| React Router | 6.x | Client-side Routing |
| Vite | 5.x | Build Tool + Dev Server |
| Tailwind CSS | 3.x | Utility-First CSS |
| Zustand | — | State Management |
| Axios | — | HTTP-Client |
| Tiptap | 3.x | Rich-Text-Editor |
| @dnd-kit | 6.x | Drag & Drop |
| Capacitor | 8.x | Native Android-App |
| idb | — | IndexedDB (Offline) |
| vite-plugin-pwa | — | PWA / Service Worker |

### Keep-Sync Sidecar (`apps/keep-sync/`)

| Technologie | Zweck |
|-------------|-------|
| FastAPI (Python) | HTTP-Server |
| gkeepapi | Google Keep API (inoffiziell) |

### Shared Types (`packages/shared-types/`)

| Datei | Inhalt |
|-------|--------|
| `packages/shared-types/src/index.ts` | Alle TypeScript-Interfaces (User, Project, Task, Label, Comment, Filter, etc.) |

---

## Request-Flow (API)

```
HTTP Request
  │
  ├─ Fastify Middleware: Helmet, CORS, Rate Limit, Cookie
  │
  ├─ Auth: request.jwtVerify() via preHandler
  │
  ├─ Route Handler (apps/api/src/routes/*.ts)
  │     │
  │     ├─ Zod-Validierung (Request Body/Query)
  │     │
  │     ├─ Autorisierung (apps/api/src/lib/authorization.ts)
  │     │     → checkProjectAccess(userId, projectId)
  │     │     → checkProjectWriteAccess(userId, projectId)
  │     │     → getAccessibleProjectIds(userId)
  │     │
  │     ├─ Service Layer (apps/api/src/services/*.ts)
  │     │     → Geschaeftslogik + DB-Zugriff via Drizzle
  │     │
  │     └─ Response (JSON)
  │
  └─ Socket.io Broadcast (bei Mutationen)
       → io.to(`project:${projectId}`).emit('task:updated', ...)
```

---

## Authentifizierung

### JWT-Flow

1. **Login:** `POST /api/auth/login` → Access Token (15 min) + Refresh Token (90 Tage, httpOnly Cookie)
2. **Refresh:** `POST /api/auth/refresh` → Neuer Access Token + Refresh Token Rotation
3. **Jeder Request:** `Authorization: Bearer <access_token>` → `preHandler: [fastify.authenticate]`
4. **Socket.io:** Token via `handshake.auth.token`, JWT-Verifizierung im `io.use()` Middleware

### Authelia SSO (optional)

- Aktivierung: `AUTHELIA_ENABLED=true`
- Forward-Auth-Proxy setzt Header `Remote-User`
- Route: `POST /api/auth/sso`

### Autorisierung

Definiert in `apps/api/src/lib/authorization.ts`:

- **Projekt-Zugriff:** Eigentümer ODER Mitglied ODER `is_shared=1`
- **Schreibzugriff:** Eigentümer ODER Mitglied mit Rolle `owner`/`editor`
- **Rollen:** `owner` | `editor` | `viewer`

---

## WebSocket-Architektur

```
Client (React)
  │
  ├─ socket.emit('join:project', projectId)
  │     → Server prueft Zugriffsberechtigung
  │     → socket.join(`project:${projectId}`)
  │
  └─ socket.on('task:updated', callback)
       → Echtzeit-Updates innerhalb des Projekt-Raums
```

- **Server:** `apps/api/src/index.ts` (Zeile 147–200)
- **Authentifizierung:** JWT-Verifizierung bei jeder Connection
- **Rooms:** Pro Projekt (`project:<id>`)

---

## Keep-Sync Sidecar

```
apps/api (Fastify)
  │
  ├─ Timer: alle 2 Minuten → syncAllKeepMappings()
  │     → HTTP-Calls an apps/keep-sync (FastAPI)
  │
  └─ apps/keep-sync/main.py
       → Google Keep API via gkeepapi
       → Sync: Keep-Listen ↔ Todoteck-Notizen/Aufgaben
```

- Verschluesselung: AES-256-GCM fuer Google-Token (`GOOGLE_TOKEN_ENCRYPTION_KEY`)
- Konfiguration: `google_keep_accounts`, `google_keep_sync_mappings`, `google_keep_todo_config` Tabellen

---

## Deployment-Architektur

```
Developer
  │
  ├─ Feature-Branch → PR → Merge in main
  │
  ├─ GitHub Actions (Self-Hosted Runner)
  │     → Build: 3 Docker-Images (api, web, keep-sync)
  │     → Push nach GHCR (Tags: latest + SHA)
  │
  └─ Portainer (GitOps Polling)
       → docker-compose.yml aus docker-configs Repo
       → Automatisches Redeploy bei Aenderungen
```

- **Registry:** `ghcr.io/fauteck/todo-api`, `ghcr.io/fauteck/todo-web`, `ghcr.io/fauteck/todo-keep-sync`
- **Image-Tags:** `latest` + kurzer SHA-Commit-Hash
- **Kein SemVer / keine Git-Tags** fuer Image-Releases

---

## Verwandte Dokumente

- [README.md](../README.md) — Architektur-Diagramm (ASCII), Feature-Uebersicht
- [docs/datenbank.md](datenbank.md) — Drizzle-Schema, Tabellen, Beziehungen
- [docs/api-patterns.md](api-patterns.md) — Route-Struktur, Services, Plugins
