# API-Patterns

← [Zurueck zum Index](../CLAUDE.md)

---

## Uebersicht

Die API folgt einem 3-Schicht-Muster:

```
Route (HTTP-Handler)  →  Service (Geschaeftslogik)  →  Drizzle (DB-Zugriff)
     ↑                         ↑                           ↑
  Zod-Validierung        Authorization-Lib           Schema (schema.ts)
```

---

## Route-Dateien

Alle Route-Dateien liegen in `apps/api/src/routes/`:

| Datei | Prefix | Beschreibung |
|-------|--------|-------------|
| `auth.ts` | `/api/auth/*` | Login, Logout, Refresh, SSO, Passwort aendern |
| `projects.ts` | `/api/projects/*` | CRUD Projekte, Mitglieder, Archivierung |
| `tasks.ts` | `/api/projects/:id/tasks/*`, `/api/notes`, `/api/today`, `/api/upcoming` | Aufgaben + Notizen |
| `labels.ts` | `/api/labels/*` | CRUD Labels, Label-Aufgaben-Zuordnung |
| `filters.ts` | `/api/filters/*` | Benutzerdefinierte Filter |
| `search.ts` | `/api/search` | Volltextsuche |
| `activity.ts` | `/api/activity/*` | Aktivitaets-Feed |
| `ics.ts` | `/api/ics/*` | iCalendar-Export |
| `public.ts` | `/api/public/*` | Public API (Token-Auth) |
| `widget.ts` | `/api/widget/*` | Android Widget Endpunkte |
| `import.ts` | `/api/import/*` | Markdown-Import |
| `keep.ts` | `/api/keep/*` | Google Keep Sync |
| `google-calendar.ts` | `/api/google-calendar/*` | Google Calendar iCal |

---

## Route-Registrierung

Routen werden als Fastify-Plugins registriert (`apps/api/src/index.ts`):

```typescript
// apps/api/src/index.ts
await fastify.register(authRoutes);
await fastify.register(projectRoutes);
await fastify.register(taskRoutes);
// ... weitere Routes
```

Jede Route-Datei exportiert eine async Funktion:

```typescript
// apps/api/src/routes/tasks.ts
export async function taskRoutes(fastify: FastifyInstance) {
  fastify.get('/notes', { preHandler: [fastify.authenticate] }, async (request) => {
    // ...
  });
}
```

---

## Authentifizierung in Routes

Geschuetzte Routen nutzen den `preHandler`:

```typescript
fastify.get('/endpoint', { preHandler: [fastify.authenticate] }, async (request) => {
  const userId = request.user.sub;  // JWT-Payload: { sub: userId, username: email }
  // ...
});
```

Das Auth-Plugin (`apps/api/src/plugins/auth.ts`) dekoriert `fastify.authenticate`, das `request.jwtVerify()` aufruft.

---

## Validierung mit Zod

Request-Bodies werden mit Zod-Schemas validiert:

```typescript
// apps/api/src/routes/tasks.ts
const createTaskSchema = z.object({
  title: z.string().min(1).max(500),
  type: z.enum(['todo', 'note']).optional(),
  description: z.string().max(1000000).optional().nullable(),
  due_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional().nullable(),
  priority: z.number().int().min(1).max(4).optional(),
  // ...
});

// Verwendung im Handler:
fastify.post('/projects/:projectId/tasks', { preHandler: [fastify.authenticate] }, async (request, reply) => {
  const body = createTaskSchema.parse(request.body);
  // ...
});
```

---

## Service-Layer

Services kapseln die Geschaeftslogik und DB-Zugriffe:

| Datei | Funktionen |
|-------|-----------|
| `apps/api/src/services/taskService.ts` | `getNotesForUser()`, `getTasksForProject()`, `getTodayTasks()`, `getUpcomingTasks()`, `createTask()`, `buildTaskUpdates()`, `deleteTask()`, `getTaskLabelsMap()`, `batchMoveOverdueToToday()`, `bulkArchiveDone()`, `exportTaskAsMarkdown()`, `logActivity()` |
| `apps/api/src/services/projectService.ts` | Projekt-Logik |
| `apps/api/src/services/searchService.ts` | Volltextsuche (FTS5 / LIKE-Fallback) |
| `apps/api/src/services/importService.ts` | Markdown → Tiptap JSON Konvertierung |
| `apps/api/src/services/keepService.ts` | Google-Keep-Integration: Account-Verwaltung, Sync-Mappings, Checklist-Widget-Endpoints, To-Do-Liste-Config. Wirft `KeepServiceError` mit `status`/`code`, die Route mappt sie auf HTTP-Responses. |

### Beispiel: Service-Nutzung in Route

```typescript
// apps/api/src/routes/tasks.ts
import { getTodayTasks, createTask, logActivity } from '../services/taskService';

fastify.get('/today', { preHandler: [fastify.authenticate] }, async (request) => {
  const userId = request.user.sub;
  const { limit, offset } = paginationSchema.parse(request.query);
  const allTasks = getTodayTasks(userId);
  return paginatedResponse(allTasks.slice(offset, offset + limit), allTasks.length, limit, offset);
});
```

---

## Autorisierung

Definiert in `apps/api/src/lib/authorization.ts`:

| Funktion | Beschreibung |
|----------|-------------|
| `checkProjectAccess(userId, projectId)` | Prueft Lese-Zugriff (Owner, Member, oder is_shared) |
| `checkProjectWriteAccess(userId, projectId)` | Prueft Schreib-Zugriff (Owner oder Editor-Rolle) |
| `getAccessibleProjectIds(userId)` | Gibt alle Projekt-IDs zurueck, auf die der User Zugriff hat |

Verwendung in Routen:

```typescript
if (!await checkProjectAccess(userId, projectId)) {
  return reply.code(403).send({ error: 'Access denied' });
}
```

---

## Pagination

Definiert in `apps/api/src/lib/pagination.ts`:

```typescript
import { paginationSchema, paginatedResponse } from '../lib/pagination';

// Query-Parameter: ?limit=20&offset=0
const { limit, offset } = paginationSchema.parse(request.query);

// Response-Format: { data: [...], total: 42, has_more: true }
return paginatedResponse(items, total, limit, offset);
```

---

## Plugins

| Datei | Beschreibung |
|-------|-------------|
| `apps/api/src/plugins/auth.ts` | JWT-Authentifizierung, dekoriert `fastify.authenticate` |

Weitere Fastify-Plugins werden direkt in `index.ts` registriert:
- `@fastify/helmet` — Security Headers (CSP, HSTS, etc.)
- `@fastify/cors` — CORS-Konfiguration
- `@fastify/cookie` — Cookie-Handling (Refresh Tokens)
- `@fastify/jwt` — JWT-Verifizierung
- `@fastify/rate-limit` — Rate Limiting (100 req/min)

---

## Lib-Module

| Datei | Beschreibung |
|-------|-------------|
| `apps/api/src/lib/authorization.ts` | Zugriffspruefung (Projekt-Rollen) |
| `apps/api/src/lib/pagination.ts` | Pagination-Schema + Response-Helper |
| `apps/api/src/lib/recurrence.ts` | Wiederkehrende Aufgaben (naechstes Datum berechnen) |
| `apps/api/src/lib/tiptapConverter.ts` | Tiptap JSON ↔ Markdown Konvertierung |
| `apps/api/src/lib/keepClient.ts` | HTTP-Client fuer Keep-Sync Sidecar |
| `apps/api/src/lib/keepSync.ts` | Keep-Sync Logik (Push, Pull, Timer) |
| `apps/api/src/lib/icalParser.ts` | Google Calendar iCal Parsing |
| `apps/api/src/lib/encryption.ts` | AES-256-GCM Token-Verschluesselung |

---

## How-To: Neue Route hinzufuegen

1. **Route-Datei erstellen:** `apps/api/src/routes/meine-route.ts`

```typescript
import { FastifyInstance } from 'fastify';
import { z } from 'zod';

const mySchema = z.object({ name: z.string().min(1) });

export async function meineRoutes(fastify: FastifyInstance) {
  fastify.get('/api/mein-endpoint', { preHandler: [fastify.authenticate] }, async (request) => {
    const userId = request.user.sub;
    // ...
    return { data: [] };
  });
}
```

2. **Route registrieren** in `apps/api/src/index.ts`:

```typescript
import { meineRoutes } from './routes/meine-route';
// ...
await fastify.register(meineRoutes);
```

3. **Optional: Service erstellen** in `apps/api/src/services/` fuer komplexe Logik

---

## Verwandte Dokumente

- [docs/architektur.md](architektur.md) — Request-Flow, Auth-Flow
- [docs/datenbank.md](datenbank.md) — Drizzle-Schema, Tabellen
- [docs/haeufige-aufgaben.md](haeufige-aufgaben.md) — End-to-End Feature-Guide
- [README.md](../README.md) — Vollstaendige API-Endpunkt-Referenz
