# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/).
This project does not use SemVer or Git tags — production images are tagged
`latest` + commit SHA via GitOps (see [CLAUDE.md](CLAUDE.md) §4, §11). Sections
are grouped by merge date on `main` instead of by version.

Categories: **Added**, **Changed**, **Fixed**, **Security**, **Removed**,
**Deprecated**, **Docs**, **Chore**.

## [Unreleased]

### Docs
- Introduce `CHANGELOG.md` and make it mandatory in `CLAUDE.md` (Doc Index, §12 DoD, §13 Documentation Requirements)

## [2026-04-27]

### Added
- Polish magazine tab bar and add share button for public tabs (#100)
- Differentiated user-facing OpenAI error messages (#95)
- Swagger docs, 409 on duplicate feed, paginated saved list (#95)
- Mark-all-read button + GReader sync feedback (#95)
- Persist per-user item counts on each GReader sync (#95)

### Fixed
- Prioritize public magazine route over initial home route (#105)
- Forward SPA routes to `index.html` instead of resolving as view (#104)
- Guard against empty feeds list in `getPublicItems` (#103)
- Public items endpoint: make `from`/`to` optional and fix `PageResponse` parsing (#102)
- Eagerly load user when fetching public tab to prevent `LazyInitializationException` (#101)
- Date bar format `DD.MM.YYYY` instead of `MMM d, yyyy` (#100)
- Reload magazine tabs after settings close, show public share link (#99)
- Consistent header, logo, favicon, autofill, and menu cleanup (#98)
- Show Feedteck name on all screens and fix Bitwarden autofill (#97)
- Add menu navigation to all routes and clean up URLs (#97)
- Login: `AutofillGroup` + `TextEditingController`s for Bitwarden autofill (#96)
- Distinct image error state, deferred password mismatch hint (#95)
- Raise `pageSize` cap to 2000 on time-windowed item endpoints (#94)

### Chore
- Quick-win polish: search rename, signup label, env hint (#95)

## [2026-04-26]

### Added
- Activate Springdoc / Swagger UI for authenticated users — F6 (#93)
- Paginated saved list (F4) and bulk mark-as-read (F2) (#93)
- Targeted `Cache-Control` headers for lists and images — F8
- Per-user GReader sync status endpoint — F5
- Bound `pageSize` on listing endpoints — F3

### Docs
- Add `SECURITY.md` and document `FEED_SYNC_CRON` cadence — O3, O4

## [2026-04-25]

### Added
- Semantic labels on icon buttons and images for a11y — F19 (#89)

### Changed
- Refactor `main.dart` theme: remove boilerplate, DRY themes, l10n title (#90)

### Fixed
- Security hardening and performance fixes B13–B27, F1–F5 (#90)
- Provide `RestClient.Builder` bean to resolve `OidcService` startup failure (#92)
- Upgrade `flutter_secure_storage` to `^10.0.0` (#91)

### Removed
- `issues.md` audit backlog (migrated/closed)

## [2026-04-24]

### Fixed
- Drop CSP via omission instead of non-existent `.disable()` (#87)
- Re-enable security headers with Flutter-web-compatible CSP (#85)
- Login labels via `InputDecoration` instead of separate `Text` widgets (#82)
- Blank page caused by broken `@Cacheable` SpEL in `UserService` (#81)
- White Flutter-web screen due to overly restrictive CSP (#80)
- Suppress Tomcat `EOFException` debug-log noise (#79)

### Diagnostics (temporary, later reverted/superseded)
- CSP-only disable (#86)
- Full security-header disable (CSP/HSTS/Frame/CT) (#84)
- Partial frontend revert from cb6e41f / 6c3ac26 (#83)

## [2026-04-23]

### Added
- Backend audit fixes: B1, B3, B9, B10, B15, B16, B17, B19, B21 (#74)

### Security
- Audit fixes B4, B8, B11, B13, B25, B26, F1, F2, F5, F9, F19 (#75)

### Fixed
- JWT session remains valid after PBKDF2 migration (#77)
- Test compilation after Login + `StringCryptoConverter` API changes (#78)
- Align `flutter_secure_storage` with `oidc_default_store` requirement (#76)
- FreshRSS sync no longer aborts entirely on OpenAI 429 (#71)

### Docs
- Long-session / stream-timeout working rules in `CLAUDE.md` (#73)
- `issues.md` audit backlog (backend + frontend) (#72)

## [2026-04-22]

### Added
- AI activity log page in settings (#64)

### Fixed
- Consistent back button and profile menu on all secondary pages (#70)
- Article-shortening toggle now also controls server-side AI generation (#69)
- Gemini API 429 error message no longer shows `: null` (#69)
- Re-score articles without AI score on next sync (#68)
- Postgres healthcheck verifies target DB exists (#68)
- AI log shows errors, image cache hardened, Postgres healthcheck quiet (#66)
- Tests aligned with `recordSuccess` signature (#67)
- `AiActivityLogTab` import added in `router.dart` (#65)
- Add `getContent()` / `hasContent()` to `PageResponse` for test compatibility (#63)
- Classic feed shows all articles; stable `Page` JSON; fast AI skip on missing URL (#62)
- Prevent concurrent article sync and Tomcat header overflow (#61)
- NPE in `resolveImageUrl` and silent OpenAI blank-URL failure (#60)
- Trigger article sync asynchronously on GReader on-demand sync (#58)
- Tomcat startup fix (#57)

### Chore
- Remove `OPENAI_API_KEY` / `URL` / `MODEL` from `docker-compose` (#62)
- Update `docker-compose.yml`

### Docs
- Add `DESIGN.md` and translate all technical docs to English (#88, dated 2026-04-25 in git but logically part of the docs overhaul)

---

> **Earlier history:** Commits prior to 2026-04-22 are not present in the
> currently visible `git log` snapshot. They can be reconstructed from
> `origin/master` history and prepended here when needed.
