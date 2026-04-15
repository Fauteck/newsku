# Code-Konventionen

← [Zurueck zum Index](../CLAUDE.md)

---

## TypeScript

- **Strict Mode:** Aktiviert in allen `tsconfig.json`
- **Zod statt manuelle Validierung:** Request-Bodies immer mit Zod-Schema validieren
- **Shared Types:** Interfaces immer in `packages/shared-types/src/index.ts` definieren, nie lokal duplizieren

---

## Naming

### Dateien

| Kontext | Konvention | Beispiel |
|---------|-----------|---------|
| Route-Dateien | `camelCase.ts` | `apps/api/src/routes/googleCalendar.ts` |
| Service-Dateien | `camelCaseService.ts` | `apps/api/src/services/taskService.ts` |
| Lib-Module | `camelCase.ts` | `apps/api/src/lib/authorization.ts` |
| React-Seiten | `PascalCasePage.tsx` | `apps/web/src/pages/TodayPage.tsx` |
| React-Komponenten | `PascalCase.tsx` | `apps/web/src/components/TaskItem.tsx` |
| Hooks | `useCamelCase.ts` | `apps/web/src/hooks/useOfflineQuery.ts` |
| Stores | `camelCaseStore.ts` | `apps/web/src/stores/offlineStore.ts` |
| Utils | `camelCase.ts` | `apps/web/src/utils/dateParser.ts` |
| Tests | `*.test.ts` / `*.test.tsx` | `apps/api/src/__tests__/auth.test.ts` |

### Variablen & Funktionen

| Kontext | Konvention | Beispiel |
|---------|-----------|---------|
| Funktionen | `camelCase` | `getTasksForProject()`, `checkProjectAccess()` |
| Konstanten | `UPPER_SNAKE_CASE` | `SYNC_INTERVAL`, `DEFAULT_USER_DEFS` |
| DB-Spalten | `snake_case` | `created_at`, `due_date`, `parent_task_id` |
| DB-Tabellen | `snake_case` | `task_labels`, `activity_log` |
| Route-Pfade | `kebab-case` | `/api/google-calendar`, `/api/auth/refresh` |
| Interfaces | `PascalCase` | `Task`, `CreateTaskPayload`, `JWTPayload` |
| Enums/Unions | String Literals | `'open' | 'done' | 'archived'` |

---

## API-Konventionen

### Endpunkte

- **REST:** Standard CRUD-Operationen
- **Plural:** `/projects`, `/tasks`, `/labels` (nicht Singular)
- **Verschachtelung:** `/projects/:projectId/tasks` fuer Aufgaben eines Projekts
- **Spezial-Endpunkte:** `/today`, `/upcoming`, `/notes` (Top-Level Shortcuts)

### Response-Format

```typescript
// Einzelnes Objekt
{ id: "...", title: "...", ... }

// Liste (paginiert)
{ data: [...], total: 42, has_more: true }

// Fehler
{ error: "Access denied" }
```

### HTTP-Status-Codes

| Code | Verwendung |
|------|-----------|
| `200` | Erfolg (GET, PUT, PATCH) |
| `201` | Erstellt (POST) |
| `204` | Geloescht (DELETE) |
| `400` | Validierungsfehler (Zod) |
| `401` | Nicht authentifiziert |
| `403` | Keine Berechtigung |
| `404` | Nicht gefunden |
| `503` | Service degraded (Health Check) |

---

## React-Konventionen

### Komponenten

- **Funktionale Komponenten:** Immer `function` oder Arrow, keine Klassen
- **Default Export:** Seiten nutzen `export default function`
- **Named Export:** Wiederverwendbare Komponenten nutzen Named Export
- **Props:** Direkt destrukturiert oder via Interface

### Styling

- **Tailwind-First:** Keine CSS-Module oder styled-components
- **Dark Mode:** `dark:` Prefix fuer alle Dark-Mode-Styles
- **Responsive:** Mobile-First (`sm:`, `md:`, `lg:`)

### Imports

Empfohlene Reihenfolge:

```typescript
// 1. React
import React, { useState, useEffect } from 'react';
// 2. Third-Party
import { useNavigate } from 'react-router-dom';
// 3. Shared Types
import type { Task, Project } from '@familytodo/shared-types';
// 4. Lokale Module (api, hooks, stores, utils)
import { apiClient } from '../api/client';
import { useOfflineQuery } from '../hooks/useOfflineQuery';
// 5. Lokale Komponenten
import TaskItem from '../components/TaskItem';
```

---

## Fehlerbehandlung

### API (Backend)

```typescript
// Zod-Validierungsfehler werden automatisch als 400 zurueckgegeben
const body = createTaskSchema.parse(request.body);

// Manuelle Fehler
return reply.code(403).send({ error: 'Access denied' });
return reply.code(404).send({ error: 'Task not found' });
```

### Frontend

- **API-Fehler:** Automatisch via Axios-Interceptor (401 → Token Refresh → Redirect)
- **React Errors:** `ErrorBoundary` Komponente faengt Render-Fehler ab
- **Offline:** `useOfflineQuery` gibt gecachte Daten zurueck, `OfflineBanner` zeigt Status

---

## Verwandte Dokumente

- [docs/api-patterns.md](api-patterns.md) — Route-Struktur, Validierung
- [docs/frontend-patterns.md](frontend-patterns.md) — Komponenten, Hooks
