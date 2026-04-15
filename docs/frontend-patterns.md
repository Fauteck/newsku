# Frontend-Patterns

← [Zurueck zum Index](../CLAUDE.md)

---

## Uebersicht

```
App.tsx (Router + Provider)
  │
  ├─ AuthContext (Login-State, Token-Verwaltung)
  ├─ ThemeContext (Dark/Light Mode)
  │
  └─ AppLayout.tsx (Sidebar, TopBar, Outlet)
       │
       ├─ Pages (apps/web/src/pages/*.tsx)
       │     └─ Verwenden Components + Hooks + API-Client
       │
       ├─ Components (apps/web/src/components/*.tsx)
       │
       └─ Hooks (apps/web/src/hooks/*.ts)
             └─ Verwenden API-Client + Zustand Stores
```

---

## Routing

Definiert in `apps/web/src/App.tsx`:

| Pfad | Seite | Beschreibung |
|------|-------|-------------|
| `/login` | `LoginPage` | Login-Formular |
| `/register` | `RegisterPage` | Registrierung |
| `/today` | `TodayPage` | Heute faellige Aufgaben |
| `/upcoming` | `UpcomingPage` | Naechste 7 Tage |
| `/projects` | `ProjectsListPage` | Alle Projekte |
| `/projects/:id` | `ProjectPage` | Einzelprojekt (List/Board/Calendar) |
| `/notes` | `NotesPage` | Notizen-Bibliothek |
| `/notes/:noteId` | `NoteDetailPage` | Notiz-Detail + Rich-Editor |
| `/tasks/:taskId` | `TaskDetailPage` | Aufgaben-Detail |
| `/labels` | `LabelsPage` | Label-Verwaltung |
| `/labels/:labelId` | `LabelDetailPage` | Aufgaben eines Labels |
| `/filters/:filterId` | `FilterDetailPage` | Benutzerdefinierter Filter |
| `/filter/priority/:level` | `PriorityFilterPage` | Prioritaets-Filter |
| `/activity` | `ActivityFeedPage` | Aktivitaets-Feed |
| `/settings` | `SettingsPage` | Einstellungen |

Alle Routen ausser `/login` und `/register` sind durch `PrivateRoute` geschuetzt.

---

## API-Client

Definiert in `apps/web/src/api/client.ts`:

```typescript
import { apiClient } from '../api/client';

// GET-Request
const res = await apiClient.get('/projects');

// POST-Request
const res = await apiClient.post('/projects/123/tasks', { title: 'Neue Aufgabe' });

// Paginated Response unwrappen
import { unwrapPaginated } from '../api/client';
const tasks = unwrapPaginated<Task>(res);
```

**Wichtige Features:**
- **Base URL:** `/api` (Web) oder `https://todo.fauteck.eu/api` (Capacitor/Android)
- **Token-Refresh:** Automatisch bei 401-Response (mit Refresh-Lock fuer parallele Requests)
- **Capacitor:** Refresh Token in `Preferences` gespeichert (native), Cookie (web)

---

## State Management

### Contexts

| Datei | Zweck |
|-------|-------|
| `apps/web/src/contexts/AuthContext.tsx` | Auth-State: `user`, `login()`, `logout()`, `isLoading` |
| `apps/web/src/contexts/ThemeContext.tsx` | Dark/Light Mode: `theme`, `toggleTheme()` |

### Zustand Store

| Datei | Zweck |
|-------|-------|
| `apps/web/src/stores/offlineStore.ts` | Offline-Mutations-Queue (IndexedDB) |

### Pattern: Daten laden in Pages

Pages laden Daten typischerweise mit `useOfflineQuery` oder direkten `apiClient`-Calls:

```typescript
// apps/web/src/pages/TodayPage.tsx
import { useOfflineQuery } from '../hooks/useOfflineQuery';
import type { Task } from '@familytodo/shared-types';

const { data: tasks } = useOfflineQuery<Task[]>('today-tasks', '/today');
```

---

## Hooks

| Datei | Zweck | Verwendung |
|-------|-------|-----------|
| `useOfflineQuery.ts` | Daten laden mit IndexedDB-Cache | `useOfflineQuery<T>(key, url)` |
| `useOfflineMutation.ts` | Mutations mit Offline-Queue | `useOfflineMutation(url, method)` |
| `useOnlineStatus.ts` | Online/Offline erkennen | `const isOnline = useOnlineStatus()` |
| `useGoogleCalendarEvents.ts` | Google Calendar Events laden | `useGoogleCalendarEvents(date)` |

---

## Komponenten

### Kern-Komponenten

| Komponente | Datei | Beschreibung |
|-----------|-------|-------------|
| `TaskItem` | `components/TaskItem.tsx` | Einzelne Aufgabe (Checkbox, Prioritaet, Datum, Assignee) |
| `AddTaskForm` | `components/AddTaskForm.tsx` | Aufgabe erstellen (Desktop-Formular) |
| `AddTaskSheet` | `components/AddTaskSheet.tsx` | Aufgabe erstellen (Mobile Bottom Sheet) |
| `TaskEditModal` | `components/TaskEditModal.tsx` | Aufgabe bearbeiten (Modal) |
| `SortableTaskList` | `components/SortableTaskList.tsx` | Drag & Drop Aufgabenliste (@dnd-kit) |
| `RichEditor` | `components/RichEditor.tsx` | Tiptap Rich-Text Editor (mit vielen Extensions, Slash-Menü & Markdown-Input-Rules) |

### Ansichten

| Komponente | Datei | Beschreibung |
|-----------|-------|-------------|
| `BoardView` | `components/BoardView.tsx` | Kanban-Board Layout |
| `CalendarView` | `components/CalendarView.tsx` | Kalender-Raster |
| `EisenhowerMatrixView` | `components/EisenhowerMatrixView.tsx` | Eisenhower-Matrix |

### UI-Elemente

| Komponente | Datei | Beschreibung |
|-----------|-------|-------------|
| `SearchOverlay` | `components/SearchOverlay.tsx` | Volltextsuche-Overlay |
| `QuickDatePicker` | `components/QuickDatePicker.tsx` | Schnelle Datumsauswahl |
| `MobileDateBar` | `components/MobileDateBar.tsx` | Mobile Datums-Navigation |
| `RecurrencePicker` | `components/RecurrencePicker.tsx` | Wiederholung konfigurieren |
| `AssigneePicker` | `components/AssigneePicker.tsx` | Benutzer-Auswahl |
| `CollapsibleGroup` | `components/CollapsibleGroup.tsx` | Einklappbare Gruppe |
| `Toast` | `components/Toast.tsx` | Toast-Benachrichtigungen |
| `EmptyState` | `components/EmptyState.tsx` | Leere-Seite Platzhalter |
| `ErrorBoundary` | `components/ErrorBoundary.tsx` | React Error Boundary |
| `OfflineBanner` | `components/OfflineBanner.tsx` | Offline-Hinweis Banner |

---

## RichEditor-Features

Der `RichEditor` (`components/RichEditor.tsx`) ist eine Tiptap-basierte WYSIWYG-Komponente für Notizen und Aufgaben-Beschreibungen. Er bietet zwei schnelle Eingabewege neben der klassischen Toolbar:

### Slash-Menü (`/`)

Tippt der Nutzer `/` am Blockanfang oder nach einem Whitespace, öffnet sich ein Auswahl-Popup mit gruppierten Einfüge-Aktionen. Gleiches Popup erscheint nach Klick auf den **+-Block-Button** rechts oben im Toolbar-Header (primär für Touch-Geräte, an denen `/` über eine Sekundärtastatur erreicht werden müsste).

| Gruppe | Befehle |
|--------|---------|
| Struktur | `/h1`, `/h2`, `/h3`, `/p` (Paragraph zurücksetzen) |
| Listen | `/ul`, `/ol`, `/todo` |
| Blöcke | `/quote`, `/code`, `/hr`, `/pagebreak` |
| Hinweise | `/info`, `/tip`, `/warn` (Admonition-Wrapper) |
| Daten | `/table` (3×3), `/math` (Inline-LaTeX) |

Neue Einträge: In `RichEditor.tsx` das Array `SLASH_COMMANDS` erweitern (typisiert via `SlashCommandItem`). Filterung läuft über `label`, `id` und `keywords[]`. Die Suggestion-Logik ist in `utils/slashCommands.ts` zentralisiert und kann in anderen Editor-Instanzen wiederverwendet werden.

### Markdown-Input-Rules

StarterKit + CodeBlockLowlight aktivieren bereits die gängigen Markdown-Eingaben beim Tippen (Überschriften, Listen, Blockquote, Codeblock, Horizontal Rule, `**fett**`, `*kursiv*`, `~~durch~~`, `` `code` ``). Die Highlight-Extension liefert `==text==`.

`utils/markdownInputRules.ts` ergänzt drei weitere Rules:

| Eingabe | Resultat |
|---------|----------|
| `[label](https://…)` bzw. `(mailto:…)` / `(/pfad)` | Text mit Link-Mark |
| `[ ] ` / `[x] ` am Zeilenstart | Task-List-Eintrag (stets uncheck, via Klick toggelbar) |
| `:::info ` / `:::warn ` / `:::tip ` (+ `warning`/`note`/`danger` als Aliase) | Admonition-Wrapper |

Alle Rules werden nur im Notiz-Modus geladen (d. h. nicht in `keepChecklistOnly`-Editoren für Google-Keep-Sync).

---

## Styling

- **Framework:** Tailwind CSS 3.x (Utility-First)
- **Konfiguration:** `apps/web/tailwind.config.js`
- **Globale Styles:** `apps/web/src/index.css`
- **Dark Mode:** Tailwind `dark:` Prefix, gesteuert durch `ThemeContext`
- **Responsive:** Mobile-First mit Tailwind Breakpoints (`sm:`, `md:`, `lg:`, `xl:`)

---

## Shared Types

Frontend und Backend teilen TypeScript-Interfaces ueber `@familytodo/shared-types`:

```typescript
import type { Task, Project, Label, Filter } from '@familytodo/shared-types';
```

Definiert in `packages/shared-types/src/index.ts`. Aenderungen dort wirken sich auf beide Apps aus.

---

## Capacitor (Android)

- **Konfiguration:** `apps/web/capacitor.config.ts`
- **Native Projekt:** `apps/web/android/`
- **API-URL:** `https://todo.fauteck.eu/api` (hardcoded in `client.ts` fuer native)
- **Token-Speicherung:** `@capacitor/preferences` (statt Cookie)
- **Build:** `npm run build` → `npx cap sync` → Android Studio

---

## How-To: Neue Seite hinzufuegen

1. **Seite erstellen:** `apps/web/src/pages/MeineSeite.tsx`

```typescript
import React from 'react';
import type { Project } from '@familytodo/shared-types';
import { useOfflineQuery } from '../hooks/useOfflineQuery';

export default function MeineSeite() {
  const { data } = useOfflineQuery<Project[]>('my-data', '/my-endpoint');
  return (
    <div className="p-4">
      <h2 className="text-xl font-bold dark:text-white">Meine Seite</h2>
      {/* Inhalt */}
    </div>
  );
}
```

2. **Route hinzufuegen** in `apps/web/src/App.tsx`:

```typescript
import MeineSeite from './pages/MeineSeite';
// Im Router:
<Route path="meine-seite" element={<MeineSeite />} />
```

3. **Navigation hinzufuegen** in `AppLayout.tsx` (Sidebar-Link)

---

## Verwandte Dokumente

- [docs/api-patterns.md](api-patterns.md) — Backend-Endpunkte
- [docs/code-konventionen.md](code-konventionen.md) — TypeScript/React Patterns
- [docs/haeufige-aufgaben.md](haeufige-aufgaben.md) — End-to-End Feature-Guide
