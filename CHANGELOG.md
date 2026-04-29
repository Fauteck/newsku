# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/).
This project does not use SemVer or Git tags — production images are tagged
`latest` + commit SHA via GitOps (see [CLAUDE.md](CLAUDE.md) §4, §11). Sections
are grouped by merge date on `main` instead of by version.

Categories: **Added**, **Changed**, **Fixed**, **Security**, **Removed**,
**Deprecated**, **Docs**, **Chore**.

## [Unreleased]

### Added
- Public magazine endpoint `GET /api/public/magazine/{tabId}` returning tab metadata for the shared link header

### Changed
- Public magazine view now mirrors the owner's view 1:1: loads the same 3 × 24h time blocks with the tab's minimum importance and AI ranking, and shows the magazine name centered in the header
- Drop default `'Top stories'` title prefill on new `topStories` layout blocks; users opt-in to a heading

### Fixed
- Public magazine route now renders the configured layout (Top Stories, grids, headlines) instead of a plain feed list
- GReader sync no longer blocks the feed view on slow AI backends: items are persisted before AI scoring, enrichment runs asynchronously, sync status surfaces "stale" after 40 min, and overlapping cron ticks are skipped

### Docs
- Introduce `CHANGELOG.md` and make it mandatory in `CLAUDE.md` (Doc Index, §12 DoD, §13 Documentation Requirements)
- Backfill pre-2026-04-22 history (PRs #1–#56) from GitHub PR titles

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
- Ollama support and optimised AI scoring for fresh installations (#55)

### Fixed
- Add environment variable validation and improve database healthcheck (#57)
- CI build: update `MockOpenaiService` signature (#56)
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

### Chore
- Remove `OPENAI_API_KEY` / `URL` / `MODEL` from `docker-compose` (#62)
- Update `docker-compose.yml`

### Docs
- Add `DESIGN.md` and translate all technical docs to English (#88, dated 2026-04-25 in git but logically part of the docs overhaul)

## [2026-04-17]

### Added
- Cron-based GReader sync 3×/h + `CLAUDE.md` corrections (#51)
- Stats page: AI tab, consistent menu, compact mobile filters (#48)
- Encrypt GReader/OpenAI credentials, persist settings, per-use-case usage tracking (#43)

### Changed
- Use FreshRSS timestamps; lower sync interval to 15 min (#50)

### Fixed
- Persist articles on OpenAI failure + manual disable path (#54)
- Abort sync cycle immediately on OpenAI 429 quota error (#53)
- Forward missing ENV variables to `newsku` container in compose (#52)
- Import `Settings-AI-Tab` in `router.dart` (#49)
- JPA query resolution for `gReader*Id` properties (#47)
- Load feeds in settings tab immediately when GReader mode active (#46)
- Restore `gReader` JSON property names so settings persist (#45)
- Flutter web build errors in generated freezed files (#44)
- Persist per-user GReader credentials and refresh bottom-nav (#41)
- Persist RSS items even when OpenAI analysis is unavailable (#42)
- Align `FeedItemController` test calls with new `getItems` signature (#40)
- Two Flutter web build compilation errors (#39)
- Feeds page navigation, mobile fixes & filter (#38)

## [2026-04-16]

### Added
- Magazine tabs with per-tab AI settings and public access (#29)
- Configurable feed-sync interval via `FEED_SYNC_INTERVAL_MS` (#35)
- Standard layout config, classic-feeds nav, page-level scroll, grouped block config (#36)
- Cache clearing, AI text shortening, UI cleanups (#20)
- Sync FreshRSS bookmarks (#33)
- FreshRSS feed settings (#17)

### Security
- Move FreshRSS credentials from per-user DB fields to environment variables (#15)

### Changed
- Redesign settings page: German UI, merged tabs, FreshRSS env-var flow (#14)
- Remove tag display, more text, hide empty image slot, og:image fallback (#19)
- Reworked settings tabs (Flutter) (#26)
- FreshRSS integration settings (#27)
- Align menu navigation (#23)
- Simplify licenses page (#24)

### Fixed
- Auto-route navigation (#30)
- Magazine tabs display (#34)
- Settings page issues (#22)
- Import `utils.dart` in `ClassicFeedCubit` for `serverUrl` getter (#37)
- Keyboard shortcuts no longer block text input; horizontal section titles; `media:content` image support (#18)
- Remove `const` from non-const `LoadingIndicator` constructor call (#16)
- JWT auth filter setting 401 before chain continues (#10)
- Missing `processFeedItem` overload in `MockOpenaiService` (#9)

### Chore
- Update runner versions (#25, #28, #31, #32)
- Pass `shortTitle`/`shortTeaser` to `MockOpenaiService` in tests (#21)
- Postgres config setup (#11)
- Spring Boot news setup (#12)
- New session housekeeping (#13)

## [2026-04-15]

### Added
- Feed category management (#1)
- Saved articles, text-truncation settings, swipe gestures, keyboard shortcuts (#5)
- FreshRSS backend integration via Google Reader API (#7, #8)

### Changed
- Build Flutter web before Maven and embed into `static/` (#3)

### Chore
- Initial newsku fork setup (#2)
- App-review improvements (#4)
- Docker setup for newsku (#6)

---

> **Earlier history reconstructed from GitHub PR titles** (PRs #1–#56), since
> the local `git log` snapshot only goes back to 2026-04-22. The corresponding
> commits are not present in `origin/master` (history was rewritten at some
> point); these entries reflect what was merged according to the GitHub PR
> record.
