# Testing

← [Zurueck zum Index](../CLAUDE.md)

---

## Uebersicht

| App | Framework | Testverzeichnis | Befehl |
|-----|-----------|----------------|--------|
| API | Vitest 1.x | `apps/api/src/__tests__/` | `npm run test --workspace=apps/api` |
| Web | Vitest | `apps/web/src/__tests__/` | `npm run test --workspace=apps/web` |
| Alle | Vitest | — | `npm run test` (Root) |

---

## Test-Befehle

```bash
# Alle Tests (alle Workspaces)
npm run test

# Nur API-Tests
npm run test --workspace=apps/api

# Nur Web-Tests
npm run test --workspace=apps/web

# Tests im Watch-Modus (Entwicklung)
cd apps/api && npx vitest

# Einzelnen Test ausfuehren
cd apps/api && npx vitest run src/__tests__/auth.test.ts
```

---

## API-Tests

### Vorhandene Tests

| Datei | Beschreibung |
|-------|-------------|
| `apps/api/src/__tests__/setup.ts` | Test-Setup: In-Memory SQLite DB, Fastify-Instanz |
| `apps/api/src/__tests__/auth.test.ts` | Auth-Routen (Login, Refresh, Passwort) |
| `apps/api/src/__tests__/health.test.ts` | Health-Endpunkt `/health` |
| `apps/api/src/__tests__/pagination.test.ts` | Pagination Helper (paginationSchema, paginatedResponse) |
| `apps/api/src/__tests__/searchService.test.ts` | Such-Service (FTS, LIKE-Fallback) |
| `apps/api/src/__tests__/importService.test.ts` | Import-Service (Markdown → Tiptap) |

### Test-Setup

Das Setup (`setup.ts`) erstellt eine In-Memory SQLite-Datenbank und eine Fastify-Instanz mit allen Plugins und Routen:

```typescript
// apps/api/src/__tests__/setup.ts
// Stellt bereit:
// - Fastify-Instanz (app) mit allen Plugins
// - In-Memory DB (kein Dateisystem)
// - Test-User fuer Auth-Tests
```

### Test-Pattern (API)

```typescript
import { describe, it, expect } from 'vitest';

describe('GET /health', () => {
  it('should return ok status', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/health',
    });
    expect(response.statusCode).toBe(200);
    expect(response.json()).toEqual({ status: 'ok', database: 'ok' });
  });
});
```

API-Tests nutzen `app.inject()` (Fastify's Lightweight Testing) statt HTTP-Requests.

---

## Web-Tests

### Vorhandene Tests

| Datei | Beschreibung |
|-------|-------------|
| `apps/web/src/__tests__/dateParser.test.ts` | Datum-Parsing + Formatierung |
| `apps/web/src/__tests__/markdownPaste.test.ts` | Markdown-Paste im Editor |

### Test-Pattern (Web)

```typescript
import { describe, it, expect } from 'vitest';
import { toDateStr } from '../utils/dateParser';

describe('dateParser', () => {
  it('should format date correctly', () => {
    expect(toDateStr(new Date('2026-03-15'))).toBe('2026-03-15');
  });
});
```

Web-Tests testen primaer Utility-Funktionen. Komponenten-Tests sind noch nicht implementiert.

---

## How-To: Neuen Test schreiben

### API-Test

1. Datei erstellen: `apps/api/src/__tests__/meinTest.test.ts`

```typescript
import { describe, it, expect, beforeAll } from 'vitest';
// Setup importieren (erstellt App + DB)
import { app, testUser } from './setup';

describe('GET /api/mein-endpoint', () => {
  it('should require authentication', async () => {
    const res = await app.inject({ method: 'GET', url: '/api/mein-endpoint' });
    expect(res.statusCode).toBe(401);
  });

  it('should return data', async () => {
    const res = await app.inject({
      method: 'GET',
      url: '/api/mein-endpoint',
      headers: { authorization: `Bearer ${testUser.token}` },
    });
    expect(res.statusCode).toBe(200);
  });
});
```

2. Test ausfuehren: `cd apps/api && npx vitest run`

### Web-Test (Utility)

1. Datei erstellen: `apps/web/src/__tests__/meinUtil.test.ts`

```typescript
import { describe, it, expect } from 'vitest';
import { meineFunction } from '../utils/meinUtil';

describe('meineFunction', () => {
  it('should work correctly', () => {
    expect(meineFunction('input')).toBe('expected');
  });
});
```

2. Test ausfuehren: `cd apps/web && npx vitest run`

---

## Verwandte Dokumente

- [docs/entwicklung.md](entwicklung.md) — Dev-Setup, Scripts
- [docs/api-patterns.md](api-patterns.md) — API-Struktur (was getestet wird)
