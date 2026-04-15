# Haeufige Aufgaben

← [Zurueck zum Index](../CLAUDE.md)

---

## 1. Neue API-Route + Frontend-Seite (End-to-End)

### Dateien die geaendert/erstellt werden

| Datei | Aktion |
|-------|--------|
| `packages/shared-types/src/index.ts` | Interface + Payload hinzufuegen |
| `apps/api/src/routes/meine-route.ts` | Neue Route-Datei erstellen |
| `apps/api/src/index.ts` | Route registrieren |
| `apps/web/src/pages/MeineSeite.tsx` | Neue Seite erstellen |
| `apps/web/src/App.tsx` | Route hinzufuegen |
| `apps/web/src/pages/AppLayout.tsx` | Navigation-Link hinzufuegen |

### Schritte

1. **Shared Type definieren** (`packages/shared-types/src/index.ts`):
```typescript
export interface MeinDing {
  id: string;
  name: string;
  created_at: string;
}
```

2. **API-Route erstellen** (`apps/api/src/routes/meine-route.ts`):
```typescript
import { FastifyInstance } from 'fastify';
import { z } from 'zod';

export async function meineDingRoutes(fastify: FastifyInstance) {
  fastify.get('/api/meine-dinge', { preHandler: [fastify.authenticate] }, async (request) => {
    const userId = request.user.sub;
    // DB-Query...
    return { data: [] };
  });
}
```

3. **Route registrieren** (`apps/api/src/index.ts`):
```typescript
import { meineDingRoutes } from './routes/meine-route';
await fastify.register(meineDingRoutes);
```

4. **Frontend-Seite** (`apps/web/src/pages/MeineSeite.tsx`):
```typescript
import React from 'react';
import type { MeinDing } from '@familytodo/shared-types';
import { useOfflineQuery } from '../hooks/useOfflineQuery';

export default function MeineSeite() {
  const { data } = useOfflineQuery<MeinDing[]>('meine-dinge', '/meine-dinge');
  return (
    <div className="p-4">
      <h2 className="text-xl font-bold dark:text-white">Meine Dinge</h2>
    </div>
  );
}
```

5. **Route registrieren** (`apps/web/src/App.tsx`):
```typescript
<Route path="meine-dinge" element={<MeineSeite />} />
```

---

## 2. Neues DB-Feld hinzufuegen

### Dateien die geaendert werden

| Datei | Aktion |
|-------|--------|
| `apps/api/src/db/schema.ts` | Spalte hinzufuegen |
| `apps/api/drizzle/` | Migration generieren |
| `packages/shared-types/src/index.ts` | Interface aktualisieren |
| `apps/api/src/routes/*.ts` | Zod-Schema erweitern |

### Schritte

1. **Schema aendern** (`apps/api/src/db/schema.ts`):
```typescript
// In der Tabelle:
mein_feld: text('mein_feld'),
```

2. **Migration generieren**:
```bash
cd apps/api
npx drizzle-kit generate
```

3. **Shared Type aktualisieren** (`packages/shared-types/src/index.ts`):
```typescript
mein_feld?: string | null;
```

4. **Zod-Schema anpassen** (in der relevanten Route-Datei):
```typescript
mein_feld: z.string().max(200).optional().nullable(),
```

5. **Testen**:
```bash
npm run test
```

---

## 3. Neue Komponente erstellen

### Schritte

1. **Datei erstellen:** `apps/web/src/components/MeineKomponente.tsx`

```typescript
import React from 'react';

interface MeineKomponenteProps {
  title: string;
  onAction: () => void;
}

export default function MeineKomponente({ title, onAction }: MeineKomponenteProps) {
  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg p-4 shadow-sm">
      <h3 className="font-medium dark:text-white">{title}</h3>
      <button
        className="mt-2 px-3 py-1 bg-blue-500 text-white rounded hover:bg-blue-600"
        onClick={onAction}
      >
        Aktion
      </button>
    </div>
  );
}
```

2. **Verwenden** in einer Seite:
```typescript
import MeineKomponente from '../components/MeineKomponente';
<MeineKomponente title="Titel" onAction={() => console.log('click')} />
```

---

## 4. Docker-Image lokal bauen & testen

```bash
# API-Image bauen
docker build -t todo-api:local -f apps/api/Dockerfile .

# Web-Image bauen
docker build -t todo-web:local -f apps/web/Dockerfile .

# Testen
docker run --rm -p 3000:3000 --env-file .env todo-api:local
docker run --rm -p 3001:80 todo-web:local
```

---

## 5. Neuen Zustand-Store anlegen

Datei: `apps/web/src/stores/meinStore.ts`

```typescript
import { create } from 'zustand';

interface MeinState {
  items: string[];
  addItem: (item: string) => void;
  clear: () => void;
}

export const useMeinStore = create<MeinState>((set) => ({
  items: [],
  addItem: (item) => set((state) => ({ items: [...state.items, item] })),
  clear: () => set({ items: [] }),
}));
```

Verwenden in einer Komponente:

```typescript
import { useMeinStore } from '../stores/meinStore';

function MeineKomponente() {
  const { items, addItem } = useMeinStore();
  // ...
}
```

---

## 6. WebSocket-Event hinzufuegen

### Backend (Event senden)

```typescript
// In einer Route (apps/api/src/routes/*.ts):
fastify.io?.to(`project:${projectId}`).emit('mein-event', { id: taskId, data: '...' });
```

### Frontend (Event empfangen)

```typescript
// In einer Seite/Komponente:
import { io } from 'socket.io-client';

useEffect(() => {
  const socket = io({ auth: { token: accessToken } });
  socket.emit('join:project', projectId);
  socket.on('mein-event', (data) => {
    // State aktualisieren
  });
  return () => { socket.disconnect(); };
}, [projectId]);
```

---

## 7. Neuen Test schreiben

Siehe [docs/testing.md](testing.md) fuer ausfuehrliche Anleitung.

Kurzversion:

```bash
# API-Test
# Datei: apps/api/src/__tests__/meinTest.test.ts
cd apps/api && npx vitest run

# Web-Test
# Datei: apps/web/src/__tests__/meinTest.test.ts
cd apps/web && npx vitest run
```

---

## 8. Label an Aufgabe zuweisen (API-Beispiel)

```bash
# Label erstellen
curl -X POST /api/labels \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name": "Dringend", "color": "#e74c3c"}'

# Label an Aufgabe zuweisen
curl -X POST /api/tasks/$TASK_ID/labels \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"label_id": "$LABEL_ID"}'
```

---

## Verwandte Dokumente

- [docs/api-patterns.md](api-patterns.md) — Route-Struktur, Validierung
- [docs/frontend-patterns.md](frontend-patterns.md) — Seiten, Komponenten
- [docs/datenbank.md](datenbank.md) — Schema, Migrationen
- [docs/entwicklung.md](entwicklung.md) — Setup, Scripts
