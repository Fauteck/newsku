# Issue Analysis — Code Review Against Current State

> **Date:** 2026-04-10
> **Method:** Automated code analysis of all reported issues against current `main` state.
> **Effort legend:** XS (<1h) | S (1-2h) | M (2-4h) | L (4-8h) | XL (>1 day)
> **Value legend:** High (security/stability) | Medium (UX/DX) | Low (nice-to-have)

---

## Audit Report Findings

### High

| ID | Title | Obsolete? | Effort | Value | Recommendation |
|----|-------|-----------|--------|-------|----------------|
| F-05 | Cookies `sameSite: 'none'` without CSRF | No — `sameSite: 'none'` in `routes/auth.ts:79,176,243` | M | High | Fix now |
| F-06 | Projects PATCH allows non-owner changes | No — `routes/projects.ts:102` only checks `owner_id !== userId && !is_shared`; member can change `is_shared`/`name` | M | High | Fix now |
| F-07 | Hardcoded CORS origin `claude.ai` | No — `index.ts:121-122` adds `https://claude.ai` without feature flag | S | High | Fix now |
| F-08 | Stack traces leak to client | No — no `setErrorHandler`; `comments.ts:170` has `JSON.parse(e.meta)` without try/catch | M | High | Fix now |
| F-09 | CI pipeline without quality gates | No — `publish.yml` only Docker build/push, no lint/test/typecheck/audit | M | High | Fix now |
| F-11 | Touch targets below 44x44 px | No — `TaskItem.tsx` icons `w-5 h-5` (20px) without padding/min-size | M | Medium | Backlog |
| F-12 | Icon buttons without `aria-label` | Partially — `title` present, `aria-label` missing | S | Medium | Backlog |
| F-13 | `focus:outline-none` without visible ring | **Yes** — `focus-visible:ring-2` correct in `TaskEditModal.tsx:375,495,583` | — | — | Skip |
| F-14 | API errors only in `console.error` | No — `AppLayout.tsx:54-60` no toast/user feedback | M | Medium | Backlog |
| F-15 | `JSON.parse(e.meta)` without try/catch | **Yes** in `activity.ts` (safeParseMeta exists); **No** in `comments.ts:170` | S | High | Fix now |
| F-16 | Encryption key not fail-fast validated | **Yes** — `encryption.ts:8-12` validates correctly | — | — | Skip |
| F-17 | Seed passwords in process memory | **Yes** — `migrate.ts:340-341` deletes env vars after seeding | — | — | Skip |
| F-18 | `:latest` tags in docker-compose.yml | No — lines 5, 43, 62 use `:latest` | M | Medium | Backlog |
| F-19 | Android keystore ignore commented out | **Yes** — `.gitignore:56-57` has `*.jks`/`*.keystore` active | — | — | Skip |
| F-20 | Monolithic components | No — TaskDetailPage 1232 LoC, RichEditor 1455 LoC | L | Medium | Backlog |

### Medium

| ID | Title | Obsolete? | Effort | Value | Recommendation |
|----|-------|-----------|--------|-------|----------------|
| F-21 | Missing DB indexes on FKs | Partially — `comments.author_id`, `google_keep_accounts.user_id`, `google_keep_todo_config.user_id` missing | S | Medium | Fix now |
| F-22 | Inconsistent authorisation | Mostly obsolete — `lib/authorization.ts` provides consistent helpers; rest covered by F-06 | — | — | Skip |
| F-23 | Weak password rules | No — 10 characters, no special character/zxcvbn | S | Medium | Backlog |
| F-25 | `as any` casts in routes | No — only 2 places in `auth.ts:128,196` | XS | Low | Backlog |
| F-26 | nginx.conf without Cache-Control | No — no cache headers for hashed assets | S | Medium | Fix now |
| F-28 | CSP allows `ws:` in production | No — `index.ts:94` allows `ws:` alongside `wss:` | S | Medium | Fix now |
| F-32 | Inline hex colours | No — `#3498db` and others hardcoded in 10+ files | M | Low | Backlog |
| F-35 | Tests extremely thin | No — 14 test files, ~130 cases, no coverage/E2E | M | Medium | Backlog |
| F-36 | No ESLint/Prettier | No — no config files | M | Medium | Backlog |
| F-37 | No `.editorconfig` | No | XS | Low | Backlog |
| F-38 | Dockerfiles without HEALTHCHECK | Partially obsolete — docker-compose.yml defines healthchecks | XS | Low | Skip |
| F-39 | Dockerfile non-root user too late | **Yes** — user correctly set before CMD | — | — | Skip |
| F-40 | Activity cleanup without transaction | No — SQLite autocommit sufficient for single DELETE | XS | Low | Skip |
| F-41 | tsconfig without noUnusedLocals | No — missing | XS | Low | Backlog |
| F-42 | Brotli not configured | No — gzip only | S | Low | Backlog |
| F-43 | No Dependabot/npm audit | No — no config, no CI step | S | Medium | Fix now |
| F-46 | Timing attack in login | No — `auth.ts:131` returns 401 immediately without dummy hash | S | High | Fix now |

### Low

| ID | Title | Obsolete? | Effort | Value | Recommendation |
|----|-------|-----------|--------|-------|----------------|
| F-47 | Health check with DB query | No — `/health` with `SELECT 1`, no liveness/readiness separation | S | Low | Backlog |
| F-48 | `console.error` in bootstrap() | No — before Fastify init partly justifiable | XS | Low | Skip |
| F-49 | Filter JSON not Zod-validated | **Yes** — `routes/filters.ts` uses Zod safeParse | — | — | Skip |
| F-50 | robots.txt blocks all crawlers | Partially — exists, blocks everything; acceptable for private app | XS | Low | Skip |
| F-53 | Service layer partial | Partially done — `keepService` extracted (`keep.ts` 631→293 LoC, 47→0 DB ops); `public.ts` deduplicated via `taskService.createTask`/`buildTaskUpdates`/`getTaskLabelsMap` (23→17 DB ops). `auth.ts`/`labels.ts`/`widget.ts`/`filters.ts`/`ics.ts`/`activity.ts`/`google-calendar.ts` deliberately not refactored — audit value "Low" | S | Low | Rest skip |

---

## GitHub Issues

### Security

| ID | Title | Obsolete? | Effort | Value | Recommendation |
|----|-------|-----------|--------|-------|----------------|
| SEC-009 (#346) | CSP `unsafe-inline` in styleSrc | No — Tailwind+TipTap currently require it | L | Medium | Backlog |
| SEC-006 (#345) | No account lockout | No — rate limit 10/min present, no lockout after failed attempts | M | High | Fix now |

### Architecture / Database

| ID | Title | Obsolete? | Effort | Value | Recommendation |
|----|-------|-----------|--------|-------|----------------|
| #339 | Filter IDs as comma-separated strings | No — `schema.ts:166,171,172` still text columns, no junction tables | M | Medium | Backlog |

### Features / UX

| ID | Title | Obsolete? | Effort | Value | Recommendation |
|----|-------|-----------|--------|-------|----------------|
| #143 | Archived projects UI | No — backend ready, no management UI | M | Medium | Backlog |
| #64 | Image upload in rich editor | No — URL prompt only, no upload endpoint | L | Medium | Backlog |
| #43 | Admin panel with storage metrics | No — not implemented | XL | Low | Backlog |
| #42 | Thumbnail preview in grid | No — not implemented, depends on #64 | M | Low | Backlog |
| #41 | Client-side image compression | No — not implemented, depends on #64 | M | Low | Backlog |

---

## Roadmap Features

| Feature | Implemented? | Effort | Value | Recommendation |
|---------|-------------|--------|-------|----------------|
| Release + Portainer + APK | Partially — Docker CI present, APK build missing | M | Medium | Backlog |
| Notification center + Web/Capacitor push | No — activity feed exists, no push | XL | High | Backlog |
| @Mentions in Tiptap comments | Partially — project mentions implemented, user @mentions missing | M | Medium | Backlog |
| File attachments with object store + dedup | No — prerequisite for #41, #42, #64 | XL | High | Backlog |
| Voice-first | No | XL | Low | Backlog |
| Copy links from notes | No | S | Low | Backlog |

---

## Summary

### Fix Now (12 items — security + quick wins)

| # | ID | Title | Effort |
|---|-----|-------|--------|
| 1 | F-06 | Owner-only guard on Projects PATCH | M |
| 2 | SEC-006 | Account lockout after failed attempts | M |
| 3 | F-46 | Timing attack: dummy bcrypt for unknown user | S |
| 4 | F-05 | Set sameSite to strict/lax | M |
| 5 | F-08 | Central setErrorHandler + safeParseMeta in comments.ts | M |
| 6 | F-15 | Secure JSON.parse in comments.ts:170 | S |
| 7 | F-07 | CORS feature flag for claude.ai | S |
| 8 | F-28 | Remove ws: from CSP (only wss: in prod) | S |
| 9 | F-09 | Quality gates in CI (lint, test, typecheck) | M |
| 10 | F-43 | Dependabot + npm audit in CI | S |
| 11 | F-21 | Missing DB indexes on FKs | S |
| 12 | F-26 | Cache-Control for hashed assets | S |

### Skip (11 items — obsolete or not relevant)

F-13, F-16, F-17, F-19, F-22, F-38, F-39, F-40, F-48, F-49, F-50

### Backlog (remainder)

All remaining items — medium/low value, higher effort.
