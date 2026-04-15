# Todoteck Issues — Analyse gegen aktuellen Codestand

> **Datum:** 2026-04-10
> **Methode:** Automatisierte Code-Analyse aller gemeldeten Issues gegen den aktuellen `main`-Stand.
> **Legende Aufwand:** XS (<1h) | S (1-2h) | M (2-4h) | L (4-8h) | XL (>1 Tag)
> **Legende Nutzen:** Hoch (Sicherheit/Stabilitaet) | Mittel (UX/DX) | Niedrig (Nice-to-have)

---

## Audit-Report Findings

### Hoch

| ID | Titel | Obsolet? | Aufwand | Nutzen | Empfehlung |
|----|-------|----------|---------|--------|------------|
| F-05 | Cookies `sameSite: 'none'` ohne CSRF | Nein — `sameSite: 'none'` in `routes/auth.ts:79,176,243` | M | Hoch | Fix jetzt |
| F-06 | Projects-PATCH erlaubt Nicht-Owner-Aenderungen | Nein — `routes/projects.ts:102` prueft nur `owner_id !== userId && !is_shared`; Member kann `is_shared`/`name` aendern | M | Hoch | Fix jetzt |
| F-07 | Hardcoded CORS-Origin `claude.ai` | Nein — `index.ts:121-122` fuegt `https://claude.ai` ohne Feature-Flag hinzu | S | Hoch | Fix jetzt |
| F-08 | Stack-Traces leaken an Client | Nein — kein `setErrorHandler`; `comments.ts:170` hat `JSON.parse(e.meta)` ohne try/catch | M | Hoch | Fix jetzt |
| F-09 | CI-Pipeline ohne Quality-Gates | Nein — `publish.yml` nur Docker-Build/Push, kein Lint/Test/Typecheck/Audit | M | Hoch | Fix jetzt |
| F-11 | Touch-Targets unter 44x44 px | Nein — `TaskItem.tsx` Icons `w-5 h-5` (20px) ohne Padding/Min-Size | M | Mittel | Backlog |
| F-12 | Icon-Buttons ohne `aria-label` | Teilweise — `title` vorhanden, `aria-label` fehlt | S | Mittel | Backlog |
| F-13 | `focus:outline-none` ohne sichtbaren Ring | **Ja** — `focus-visible:ring-2` korrekt in `TaskEditModal.tsx:375,495,583` | — | — | Skip |
| F-14 | API-Fehler nur in `console.error` | Nein — `AppLayout.tsx:54-60` kein Toast/User-Feedback | M | Mittel | Backlog |
| F-15 | `JSON.parse(e.meta)` ohne try/catch | **Ja** in `activity.ts` (safeParseMeta existiert); **Nein** in `comments.ts:170` | S | Hoch | Fix jetzt |
| F-16 | Encryption-Key nicht fail-fast validiert | **Ja** — `encryption.ts:8-12` validiert korrekt | — | — | Skip |
| F-17 | Seed-Passwoerter im Prozess-Memory | **Ja** — `migrate.ts:340-341` loescht Env-Vars nach Seeding | — | — | Skip |
| F-18 | `:latest`-Tags in docker-compose.yml | Nein — Zeilen 5, 43, 62 nutzen `:latest` | M | Mittel | Backlog |
| F-19 | Android-Keystore-Ignore auskommentiert | **Ja** — `.gitignore:56-57` hat `*.jks`/`*.keystore` aktiv | — | — | Skip |
| F-20 | Monolithische Komponenten | Nein — TaskDetailPage 1232 LoC, RichEditor 1455 LoC | L | Mittel | Backlog |

### Mittel

| ID | Titel | Obsolet? | Aufwand | Nutzen | Empfehlung |
|----|-------|----------|---------|--------|------------|
| F-21 | Fehlende DB-Indizes auf FKs | Teilweise — `comments.author_id`, `google_keep_accounts.user_id`, `google_keep_todo_config.user_id` fehlen | S | Mittel | Fix jetzt |
| F-22 | Inkonsistente Authorization | Groesstenteils obsolet — `lib/authorization.ts` bietet konsistente Helpers; Rest durch F-06 abgedeckt | — | — | Skip |
| F-23 | Schwache Passwort-Regel | Nein — 10 Zeichen, kein Sonderzeichen/zxcvbn | S | Mittel | Backlog |
| F-25 | `as any`-Casts in Routes | Nein — nur 2 Stellen in `auth.ts:128,196` | XS | Niedrig | Backlog |
| F-26 | nginx.conf ohne Cache-Control | Nein — keine Cache-Header fuer hashed Assets | S | Mittel | Fix jetzt |
| F-28 | CSP erlaubt `ws:` in Production | Nein — `index.ts:94` erlaubt `ws:` neben `wss:` | S | Mittel | Fix jetzt |
| F-32 | Inline-Hex-Farben | Nein — `#3498db` u.a. in 10+ Dateien hardcoded | M | Niedrig | Backlog |
| F-35 | Tests extrem duenn | Nein — 14 Testdateien, ~130 Cases, kein Coverage/E2E | M | Mittel | Backlog |
| F-36 | Keine ESLint/Prettier | Nein — keine Config-Dateien | M | Mittel | Backlog |
| F-37 | Keine `.editorconfig` | Nein | XS | Niedrig | Backlog |
| F-38 | Dockerfiles ohne HEALTHCHECK | Teilweise obsolet — docker-compose.yml definiert Healthchecks | XS | Niedrig | Skip |
| F-39 | Dockerfile Non-Root-User zu spaet | **Ja** — User korrekt vor CMD gesetzt | — | — | Skip |
| F-40 | Activity-Cleanup ohne Transaktion | Nein — SQLite autocommit reicht fuer einzelnes DELETE | XS | Niedrig | Skip |
| F-41 | tsconfig ohne noUnusedLocals | Nein — fehlt | XS | Niedrig | Backlog |
| F-42 | Brotli nicht konfiguriert | Nein — nur gzip | S | Niedrig | Backlog |
| F-43 | Kein Dependabot/npm audit | Nein — keine Config, kein CI-Step | S | Mittel | Fix jetzt |
| F-46 | Timing-Attack im Login | Nein — `auth.ts:131` gibt sofort 401 ohne Dummy-Hash | S | Hoch | Fix jetzt |

### Niedrig

| ID | Titel | Obsolet? | Aufwand | Nutzen | Empfehlung |
|----|-------|----------|---------|--------|------------|
| F-47 | Health-Check mit DB-Query | Nein — `/health` mit `SELECT 1`, keine Liveness/Readiness-Trennung | S | Niedrig | Backlog |
| F-48 | `console.error` in bootstrap() | Nein — vor Fastify-Init teils vertretbar | XS | Niedrig | Skip |
| F-49 | Filter-JSON nicht Zod-validiert | **Ja** — `routes/filters.ts` nutzt Zod safeParse | — | — | Skip |
| F-50 | robots.txt blockiert alle Crawler | Teilweise — existiert, blockiert alles; fuer private App vertretbar | XS | Niedrig | Skip |
| F-53 | Service-Layer partial | Teilweise erledigt — `keepService` extrahiert (`keep.ts` 631→293 LoC, 47→0 DB-Ops); `public.ts` dedupliziert via `taskService.createTask`/`buildTaskUpdates`/`getTaskLabelsMap` (23→17 DB-Ops). `auth.ts`/`labels.ts`/`widget.ts`/`filters.ts`/`ics.ts`/`activity.ts`/`google-calendar.ts` bewusst nicht refactored — Audit-Nutzen "Niedrig" | S | Niedrig | Rest Skip |

---

## GitHub Issues

### Sicherheit

| ID | Titel | Obsolet? | Aufwand | Nutzen | Empfehlung |
|----|-------|----------|---------|--------|------------|
| SEC-009 (#346) | CSP `unsafe-inline` in styleSrc | Nein — Tailwind+TipTap erfordern es aktuell | L | Mittel | Backlog |
| SEC-006 (#345) | Kein Account-Lockout | Nein — Rate-Limit 10/min vorhanden, kein Lockout nach Fehlversuchen | M | Hoch | Fix jetzt |

### Architektur / Datenbank

| ID | Titel | Obsolet? | Aufwand | Nutzen | Empfehlung |
|----|-------|----------|---------|--------|------------|
| #339 | Filter-IDs als kommagetrennte Strings | Nein — `schema.ts:166,171,172` weiterhin Text-Spalten, keine Junction-Tabellen | M | Mittel | Backlog |

### Features / UX

| ID | Titel | Obsolet? | Aufwand | Nutzen | Empfehlung |
|----|-------|----------|---------|--------|------------|
| #143 | Archivierte Projekte UI | Nein — Backend ready, keine Management-UI | M | Mittel | Backlog |
| #64 | Bildupload im Rich-Editor | Nein — nur URL-Prompt, kein Upload-Endpoint | L | Mittel | Backlog |
| #43 | Admin-Panel mit Storage-Metriken | Nein — nicht implementiert | XL | Niedrig | Backlog |
| #42 | Thumbnail-Vorschau im Raster | Nein — nicht implementiert, abhaengig von #64 | M | Niedrig | Backlog |
| #41 | Client-seitige Bildkomprimierung | Nein — nicht implementiert, abhaengig von #64 | M | Niedrig | Backlog |

---

## Roadmap-Features

| Feature | Implementiert? | Aufwand | Nutzen | Empfehlung |
|---------|---------------|---------|--------|------------|
| Release + Portainer + APK | Teilweise — Docker-CI vorhanden, APK-Build fehlt | M | Mittel | Backlog |
| Notification-Center + Web/Capacitor Push | Nein — Activity-Feed existiert, kein Push | XL | Hoch | Backlog |
| @Mentions in Tiptap-Kommentaren | Teilweise — Projekt-Mentions implementiert, User-@Mentions fehlen | M | Mittel | Backlog |
| Datei-Anhaenge mit Object-Store + Dedup | Nein — Voraussetzung fuer #41, #42, #64 | XL | Hoch | Backlog |
| Voice-First | Nein | XL | Niedrig | Backlog |
| Links in Notizen rauskopieren | Nein | S | Niedrig | Backlog |

---

## Zusammenfassung

### Fix jetzt (12 Items — Sicherheit + Quick-Wins)

| # | ID | Titel | Aufwand |
|---|-----|-------|---------|
| 1 | F-06 | Owner-only Guard auf Projects-PATCH | M |
| 2 | SEC-006 | Account-Lockout nach Fehlversuchen | M |
| 3 | F-46 | Timing-Attack: Dummy-bcrypt bei unbekanntem User | S |
| 4 | F-05 | sameSite auf strict/lax umstellen | M |
| 5 | F-08 | Zentraler setErrorHandler + safeParseMeta in comments.ts | M |
| 6 | F-15 | JSON.parse in comments.ts:170 absichern | S |
| 7 | F-07 | CORS Feature-Flag fuer claude.ai | S |
| 8 | F-28 | ws: aus CSP entfernen (nur wss: in Prod) | S |
| 9 | F-09 | Quality-Gates in CI (Lint, Test, Typecheck) | M |
| 10 | F-43 | Dependabot + npm audit in CI | S |
| 11 | F-21 | Fehlende DB-Indizes auf FKs | S |
| 12 | F-26 | Cache-Control fuer hashed Assets | S |

### Skip (11 Items — obsolet oder nicht relevant)

F-13, F-16, F-17, F-19, F-22, F-38, F-39, F-40, F-48, F-49, F-50

### Backlog (Rest)

Alle uebrigen Items — mittlerer/niedriger Nutzen, hoehere Aufwaende.
