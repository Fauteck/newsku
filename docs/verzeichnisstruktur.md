# Verzeichnisstruktur

← [Zurueck zum Index](../CLAUDE.md)

---

## Root

```
/home/user/todo/
├── CLAUDE.md                          # KI-Entwicklungsregeln + Dokumentations-Index
├── README.md                          # Projekt-Dokumentation (Features, API, Setup)
├── package.json                       # Monorepo-Config (npm workspaces)
├── .env.example                       # Umgebungsvariablen-Vorlage
├── docker-compose.yml                 # Docker-Stack (API, Web, Keep-Sync, Backup)
├── .github/
│   └── workflows/
│       └── publish.yml                # CI/CD: Docker-Image Build & Push (GHCR)
├── docs/                              # LLM-optimierte Entwicklungsdokumentation
│   ├── architektur.md
│   ├── verzeichnisstruktur.md         # (diese Datei)
│   ├── api-patterns.md
│   ├── frontend-patterns.md
│   ├── datenbank.md
│   ├── entwicklung.md
│   ├── code-konventionen.md
│   ├── testing.md
│   ├── haeufige-aufgaben.md
│   └── design-system.md
├── apps/
│   ├── api/                           # Fastify REST API
│   ├── web/                           # React SPA + Android
│   └── keep-sync/                     # Python FastAPI Sidecar
└── packages/
    └── shared-types/                  # Gemeinsame TypeScript-Interfaces
```

---

## Backend: `apps/api/`

```
apps/api/
├── package.json                       # Dependencies, Scripts (dev, build, test, db:*)
├── tsconfig.json                      # TypeScript-Konfiguration
├── drizzle.config.ts                  # Drizzle-Kit Konfiguration
├── drizzle/                           # Generierte SQL-Migrationen (drizzle-kit)
│   ├── 0000_*.sql
│   └── meta/
├── Dockerfile                         # Production Docker Image
└── src/
    ├── index.ts                       # Einstiegspunkt: Bootstrap, Plugins, Routes, Socket.io
    ├── db/
    │   ├── index.ts                   # SQLite-Verbindung + Drizzle-Instanz (db, sqlite)
    │   ├── schema.ts                  # Drizzle-Schema: alle Tabellen
    │   └── migrate.ts                 # Migrationen + User-Seeding
    ├── plugins/
    │   └── auth.ts                    # JWT-Auth Plugin (fastify.authenticate Decorator)
    ├── routes/
    │   ├── auth.ts                    # Login, Logout, Refresh, SSO, Passwort aendern
    │   ├── projects.ts                # CRUD Projekte, Mitglieder, Archivierung
    │   ├── tasks.ts                   # CRUD Aufgaben/Notizen, Batch-Ops, Heute/Demnaechst
    │   ├── labels.ts                  # CRUD Labels, Label-Aufgaben-Zuordnung
    │   ├── filters.ts                 # Benutzerdefinierte Filter CRUD
    │   ├── search.ts                  # Volltextsuche
    │   ├── activity.ts                # Aktivitaets-Feed
    │   ├── ics.ts                     # iCalendar-Export
    │   ├── public.ts                  # Public API (Token-Auth, kein JWT)
    │   ├── widget.ts                  # Android Widget Endpunkte
    │   ├── import.ts                  # Markdown-Import
    │   ├── keep.ts                    # Google Keep Sync Verwaltung
    │   └── google-calendar.ts         # Google Calendar iCal-Integration
    ├── services/
    │   ├── taskService.ts             # Task-Geschaeftslogik (Erstellen, Today, Upcoming, etc.)
    │   ├── projectService.ts          # Projekt-Geschaeftslogik
    │   ├── searchService.ts           # Suche (FTS / LIKE-Fallback)
    │   └── importService.ts           # Markdown → Tiptap Konvertierung
    ├── lib/
    │   ├── authorization.ts           # Zugriffspruefung (checkProjectAccess, Rollen)
    │   ├── pagination.ts              # Pagination-Schema + paginatedResponse Helper
    │   ├── recurrence.ts              # Wiederkehrende Aufgaben (Datumsberechnung)
    │   ├── tiptapConverter.ts         # Tiptap JSON ↔ Markdown
    │   ├── keepClient.ts              # HTTP-Client fuer Keep-Sync Sidecar
    │   ├── keepSync.ts                # Keep-Sync Logik (Push/Pull, Timer)
    │   ├── icalParser.ts              # Google Calendar iCal Parsing
    │   └── encryption.ts              # AES-256-GCM Token-Verschluesselung
    ├── scripts/
    │   └── reset-password.js          # CLI-Script: Passwort zuruecksetzen
    └── __tests__/
        ├── setup.ts                   # Test-Setup (In-Memory DB)
        ├── auth.test.ts               # Auth-Routen Tests
        ├── health.test.ts             # Health-Endpunkt Test
        ├── pagination.test.ts         # Pagination Helper Tests
        ├── searchService.test.ts      # Such-Service Tests
        └── importService.test.ts      # Import-Service Tests
```

---

## Frontend: `apps/web/`

```
apps/web/
├── package.json                       # Dependencies, Scripts (dev, build, test)
├── tsconfig.json
├── vite.config.ts                     # Vite + PWA Plugin Config
├── tailwind.config.js                 # Tailwind CSS Konfiguration
├── index.html                         # SPA Entry Point
├── capacitor.config.ts                # Capacitor (Android) Config
├── android/                           # Native Android-Projekt (Capacitor)
├── Dockerfile                         # Production Docker Image (nginx)
└── src/
    ├── main.tsx                       # React Entry Point
    ├── App.tsx                        # Router-Setup, AuthProvider, ThemeProvider
    ├── index.css                      # Tailwind + globale Styles
    ├── api/
    │   └── client.ts                  # Axios-Client, Token-Refresh, Capacitor-Support
    ├── contexts/
    │   ├── AuthContext.tsx             # Auth-State (Login, Logout, User)
    │   └── ThemeContext.tsx            # Dark/Light Mode Toggle
    ├── stores/
    │   └── offlineStore.ts            # Zustand Store fuer Offline-Mutations
    ├── hooks/
    │   ├── useOfflineQuery.ts         # Offline-faehige Datenabfragen (IndexedDB Cache)
    │   ├── useOfflineMutation.ts      # Offline-Mutations-Queue
    │   ├── useOnlineStatus.ts         # Online/Offline-Erkennung
    │   └── useGoogleCalendarEvents.ts # Google Calendar Events Hook
    ├── pages/
    │   ├── AppLayout.tsx              # Haupt-Layout (Sidebar, TopBar, Outlet)
    │   ├── LoginPage.tsx              # Login-Formular
    │   ├── RegisterPage.tsx           # Registrierung
    │   ├── TodayPage.tsx              # Heute-Ansicht
    │   ├── UpcomingPage.tsx           # Demnaechst-Ansicht (7 Tage)
    │   ├── ProjectPage.tsx            # Einzelprojekt (List/Board/Calendar)
    │   ├── ProjectsListPage.tsx       # Projekt-Uebersicht
    │   ├── NotesPage.tsx              # Notizen-Bibliothek
    │   ├── NoteDetailPage.tsx         # Notiz-Detail mit Rich-Editor
    │   ├── TaskDetailPage.tsx         # Aufgaben-Detail
    │   ├── LabelsPage.tsx             # Label-Verwaltung
    │   ├── LabelDetailPage.tsx        # Aufgaben eines Labels
    │   ├── FilterDetailPage.tsx       # Benutzerdefinierter Filter
    │   ├── PriorityFilterPage.tsx     # Prioritaets-Filter
    │   ├── ActivityFeedPage.tsx       # Aktivitaets-Feed
    │   └── SettingsPage.tsx           # Einstellungen
    ├── components/
    │   ├── TaskItem.tsx               # Einzelne Aufgabe (Checkbox, Prio, Datum)
    │   ├── AddTaskForm.tsx            # Aufgabe erstellen (Desktop)
    │   ├── AddTaskSheet.tsx           # Aufgabe erstellen (Mobile Bottom Sheet)
    │   ├── TaskEditModal.tsx          # Aufgabe bearbeiten (Modal)
    │   ├── SortableTaskList.tsx       # Drag & Drop Aufgabenliste (@dnd-kit)
    │   ├── BoardView.tsx              # Kanban-Board Ansicht
    │   ├── CalendarView.tsx           # Kalender-Ansicht
    │   ├── RichEditor.tsx             # Tiptap Rich-Text Editor
    │   ├── SearchOverlay.tsx          # Volltextsuche-Overlay
    │   ├── NoteCard.tsx               # Notiz-Karte
    │   ├── AssigneePicker.tsx         # Benutzer-Auswahl
    │   ├── RecurrencePicker.tsx       # Wiederholung konfigurieren
    │   ├── QuickDatePicker.tsx        # Schnelle Datumsauswahl
    │   ├── MobileDateBar.tsx          # Mobile Datums-Navigation
    │   ├── CollapsibleGroup.tsx       # Einklappbare Gruppe
    │   ├── OverdueTaskGroup.tsx       # Ueberfaellige Aufgaben
    │   ├── CalendarEventsBlock.tsx    # Google Calendar Events
    │   ├── EisenhowerMatrixView.tsx   # Eisenhower-Matrix
    │   ├── DescriptionView.tsx        # Tiptap-Inhalt Readonly
    │   ├── KeyboardShortcutsOverlay.tsx # Tastenkuerzel-Hilfe
    │   ├── EmptyState.tsx             # Leere-Seite-Platzhalter
    │   ├── ErrorBoundary.tsx          # React Error Boundary
    │   ├── OfflineBanner.tsx          # Offline-Hinweis
    │   └── Toast.tsx                  # Toast-Benachrichtigungen
    ├── utils/
    │   ├── dateParser.ts              # Datum-Parsing + Formatierung
    │   ├── dateHelpers.ts             # Datum-Hilfsfunktionen
    │   ├── markdownPaste.ts           # Markdown-Paste im Editor
    │   ├── formatRecurrenceLabel.ts   # Wiederholungs-Labels
    │   ├── recurrenceToRRule.ts       # Recurrence → RRule Konvertierung
    │   └── autoDeleteCheckedItems.ts  # Erledigte Items automatisch loeschen
    ├── plugins/
    │   └── ...                        # Tiptap-Plugin-Erweiterungen
    └── __tests__/
        ├── dateParser.test.ts         # Datum-Parsing Tests
        └── markdownPaste.test.ts      # Markdown-Paste Tests
```

---

## Keep-Sync Sidecar: `apps/keep-sync/`

```
apps/keep-sync/
├── Dockerfile                         # Python Docker Image
├── main.py                            # FastAPI Server (Google Keep API Proxy)
└── requirements.txt                   # Python Dependencies
```

---

## Shared Types: `packages/shared-types/`

```
packages/shared-types/
├── package.json
├── tsconfig.json
└── src/
    └── index.ts                       # Alle Interfaces: User, Project, Task, Label,
                                       # Comment, ActivityLog, Filter, GoogleKeep*, etc.
```

---

## Verwandte Dokumente

- [docs/api-patterns.md](api-patterns.md) — Route-Struktur im Detail
- [docs/frontend-patterns.md](frontend-patterns.md) — Seiten & Komponenten im Detail
- [docs/datenbank.md](datenbank.md) — Schema-Referenz
