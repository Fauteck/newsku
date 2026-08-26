# CLAUDE.md — Binding Rules for AI-Assisted Development

> **Scope:** This document is the **sole, authoritative rule base** for this repository.
> It supersedes any additional AI / design / README rule files. Chapters that do not
> apply to this repo (e.g. web-specific rules) are **ignored** — no additional files
> are needed.

---

## Wissensquelle: llm-wiki (Todoteck)

Zentrale, gepflegte Wissensschicht für projektübergreifendes Wissen ist das **Projekt `llm-wiki` in Todoteck** — erreichbar über den Todoteck-MCP-Server (`mcp__Todoteck__*`) oder die Todoteck-Weboberfläche.

> Es gibt **kein** Wiki-Repository auf GitHub. Ein früheres Spiegel-Repo ist archiviert und irrelevant — nicht lesen, nicht verlinken, nicht pflegen.

Pflicht vor inhaltlichen Antworten:
1. Notiz **`_index`** lesen — Katalog aller Wiki-Seiten.
2. Mindestens die Repo-Übersicht öffnen: Notiz **`newsku (Feedteck)`**.
3. Bei übergreifenden Themen die jeweilige Konzept- oder Entitäts-Notiz aus dem Katalog.

Nach faktischen Änderungen mit Wissens-Charakter: betroffene Wiki-Notiz pflegen. Spielregeln stehen in der Notiz **`_schema`** — insbesondere „eine Heimat pro Fakt", das Lifecycle-Vokabular und die Log-Rotation.

Ein `_log`-Eintrag nur bei **Entscheidungen und Korrekturen** — nicht bei reinen Inhalts-Aktualisierungen, die zeigt die Versionshistorie der Notiz ohnehin. Im Zweifel weglassen. (Experiment bis 2026-09-21, bewusst noch nicht im `_schema`.)

Werkzeuge: `search` / `get_note` zum Lesen, `append_note` für reine Ergänzungen (kein Markdown-Round-Trip), `update_note` nur für echte Korrekturen im Bestand, danach `sync_wikilinks` und `lint_wiki`.

**Arbeitsteilung:** Architektur-Überblick, Betriebsort (Stack `newsteck` auf MINT) und FreshRSS-Anbindung stehen im Wiki; API, Client und Konfiguration stehen **in diesem Repo**. Nicht duplizieren — verlinken.

---

## Documentation Index

| Document | Contents |
|----------|--------|
| [README.md](README.md) | Feature overview, architecture diagram, API reference |
| [CHANGELOG.md](CHANGELOG.md) | Chronological log of merged changes (date-grouped, no SemVer) |
| [DESIGN.md](DESIGN.md) | Design system — tokens, components, colour, typography, motion |
| [docs/architektur.md](docs/architektur.md) | Tech stack, data models, request flow, auth |
| [docs/verzeichnisstruktur.md](docs/verzeichnisstruktur.md) | Complete file tree with absolute paths |
| [docs/api-patterns.md](docs/api-patterns.md) | Spring controllers, services, repositories, validation |
| [docs/frontend-patterns.md](docs/frontend-patterns.md) | Flutter/BLoC patterns, routing, widgets |
| [docs/datenbank.md](docs/datenbank.md) | JPA/Hibernate schema, Flyway migrations, relationships |
| [docs/entwicklung.md](docs/entwicklung.md) | Setup, dev server, feature walkthrough |
| [docs/code-konventionen.md](docs/code-konventionen.md) | Style guide, naming, Java and Dart patterns |
| [docs/testing.md](docs/testing.md) | JUnit, TestContainers, Flutter tests, mocking |
| [docs/haeufige-aufgaben.md](docs/haeufige-aufgaben.md) | How-to guides for common tasks |
| [docs/issue-analyse.md](docs/issue-analyse.md) | **Zeitpunkt-Dokument** (2026-04-10): Audit-Befunde gegen den damaligen `main`-Stand. Beschreibt einen Zeitpunkt und wird nicht nachgepflegt — offene Punkte gehören nach Todoteck |

---

## Table of Contents

1. [Core Principles](#1-core-principles)
1a. [Working Style for Long Sessions (API Stability)](#1a-working-style-for-long-sessions-api-stability)
2. [Permitted / Not Permitted](#2-permitted--not-permitted)
3. [Branching, Merge, Reviews](#3-branching-merge-reviews)
4. [Image Builds (GitHub-hosted Runner)](#4-image-builds-github-hosted-runner)
5. [Quality Requirements (Gates)](#5-quality-requirements-gates)
6. [Security & Secrets](#6-security--secrets)
7. [OWASP Top 10](#7-owasp-top-10)
8. [robots.txt](#8-robotstxt)
9. [Database & Migrations](#9-database--migrations)
10. [Logging & Health](#10-logging--health)
10a. [Sync Cadence with External Services](#10a-sync-cadence-with-external-services)
11. [Build & Deployment](#11-build--deployment)
12. [Definition of Done](#12-definition-of-done)
13. [Documentation Requirements](#13-documentation-requirements)
13a. [Doku-Hygiene](#13a-doku-hygiene)
14. [README Structure (Template)](#14-readme-structure-template)
15. [Design System](#15-design-system)

---

## 1. Core Principles

- **GitOps first**: Production is updated exclusively via versioned images and declarative infrastructure rollouts.
- **No runtime hotfixes**: Bug fixes go through code change → new image → deployment.
- **Reproducibility**: A **Git tag (if used)** must always produce the same build (CI/CD is the source of truth).

---

## 1a. Working Style for Long Sessions (API Stability)

> Goal: Avoid stream timeouts (`Stream idle timeout — partial response received`). The cause is **single long operations without intermediate output**, not the number of parallel tool calls.

### Keep Output Small

- **Filter** Bash output: `head -n 100`, `tail -n 100`, `grep -E '...'`, `wc -l` instead of full logs/dumps.
- Read large files **in segments** (`Read` with `offset`/`limit`), not all at once.
- No `find . | ...` dumps of entire project trees — use targeted `find`/`rg` queries with path filters.

### Do Not Block on Long Runs

- Start builds, tests, installs, Gradle/Maven runs, and Flutter builds as **background tasks** (`run_in_background: true`), not in the foreground.
- Set realistic **timeouts** on Bash calls; hanging processes should abort quickly rather than silently blocking the stream.
- No `sleep` loops or poll-busy-waits in the main thread.

### Protect Context

- For **broad codebase research** (>3 queries, unclear scope) use the `Explore` subagent — it encapsulates large search results and returns only a summary.
- For **design decisions** use the `Plan` subagent before making extensive edits.

### Efficient Over Cautious

- Run **independent** tool calls in a single message **in parallel** (e.g. multiple `Read`s or `grep`s) — this reduces total time and therefore timeout risk.
- Sequential only when one call depends on the result of the previous.

### Structure Large Tasks

- Tasks with many file changes (>10 files or >3 logically separate sub-steps) are broken into **traceable steps**, each a self-contained unit with an intermediate result.
- Use `TodoWrite` to keep progress visible and resume seamlessly after interruptions.

---

## 2. Permitted / Not Permitted

### The AI May

- Change and refactor code (within the existing architecture)
- Create/modify files (including tests and documentation)
- Adjust build/CI configuration (if necessary and justified)
- Adjust CI/CD workflows (runner choice, gates, build steps)

### The AI Must NOT

- Suggest `docker compose up` as **production operation**
- Manipulate containers directly (exec, hotpatch, manual changes)
- Make changes directly in Portainer
- Recommend manual `docker build` or `docker push` **for production**
- Make infrastructure assumptions (host paths, volumes, networks) unless explicitly provided

> Note: `docker compose` can be useful for **local development**, but is **not** the production operation/deploy path.

---

## 3. Branching, Merge, Reviews

- Development on feature/fix branches
- Merge via Pull Request
- `main` is release-ready / production-near and protected
- **No CI runs on a PR, and nothing blocks a bad merge.** `build-docker.yml` is
  the only workflow; it triggers on **push to `main`** (and `workflow_dispatch`).
  Its `quality` job runs the JUnit suite, but non-blocking — `continue-on-error`
  is set and `build-and-push` declares no `needs:`, so the image is published
  from whatever landed on `main` (§5). The gate before the merge is therefore
  the **PR review** plus a local run, nothing else.
- Before merging, run what covers the change locally — `mvn test` for the Spring
  side, `flutter test` for the app — and state in the PR which commands were run
  and their result.

Recommended branch naming: `feature/...`, `fix/...`, `chore/...`

PR includes: purpose, scope, test notes, possible breaking changes

---

## 4. Image Builds (GitHub-hosted Runner)

Custom images are built via GitHub Actions on GitHub-hosted `ubuntu-latest` —
**not** on a self-hosted runner.

- **No GitHub Releases / no SemVer / no Git tags** as "release mechanism" for custom images
- Build trigger: push to `main` (after PR merge) or manually via `workflow_dispatch`
- Images receive **container tags** `latest` + short SHA commit hash
- Registry: GHCR (`ghcr.io/<owner>/<image>`)
- Every merge to `main` automatically produces a new image

---

## 5. Quality Requirements (Gates)

> **There is still no gate in this repo — but there is now a measurement.**
> Since 2026-08-26 `build-docker.yml` has a `quality` job that runs
> `mvn test`. It carries **`continue-on-error: true`**, and `build-and-push`
> does **not** declare `needs: quality`. A red suite therefore blocks nothing:
> a push to `main` still builds and pushes an image, and the JAR is still built
> with `-DskipTests`.
>
> That is deliberate and temporary. The suite had never run anywhere, so its
> state was unknown — turning it into a blocking gate in one step would have
> risked freezing every release on a failure nobody had seen yet. See §5a for
> the two lines that turn the measurement into a gate.

The list below is what must hold before a merge. Since nothing enforces it, it
holds only if a human checks it:

- Tests run locally (`mvn test`, `flutter test`)
- Linting/formatting is consistent
- No debug output / temporary workarounds
- No unused ENV variables

### 5a. Turning the measurement into a gate

The job exists; two changes make it binding. Do **both** or neither — one alone
is worse than the current state, because it looks like a gate without being one:

1. Remove `continue-on-error: true` from the `quality` job.
2. Add `needs: quality` to `build-and-push`.

**When:** after the job has come back green twice on `main`. Watch the first
runs — the local run on 2026-08-26 produced 67 tests, 0 failures and 35 errors,
and all 35 came from `TestContainerTest` subclasses failing to start a Postgres
container. That was a missing Docker daemon in the local sandbox, not a broken
test; `ubuntu-latest` has one, so CI is the first place a real verdict exists.
The `quality` job uploads its surefire reports as an artifact for exactly that
reason.

Optional third step, independent of the gate: drop `-DskipTests` from the
packaging command, or keep it — with a green `quality` job in front, packaging
does not need to run the suite a second time.

**Until step 1 and 2 are done, no rule in this file may claim that CI checks
anything.** It measures.

---

## 6. Security & Secrets

- No secrets in code or repo
- No tokens/keys in logs
- Never commit `.env` — use `.env.example` instead
- Secrets exclusively via ENV/secret management
- No "default admin password" in production images

---

## 7. OWASP Top 10

During development the OWASP Top 10 **must** be considered:
https://owasp.org/Top10/2025/

**Rule:** If this repo provides web/API endpoints, OWASP applies as a minimum checklist. If not (e.g. CLI/lib), OWASP applies by analogy (input validation, supply chain, secrets, logging).

---

## 8. robots.txt

> Applies only to publicly accessible web applications. Ignore for libraries/CLIs.

Every publicly accessible web application **must** provide a `robots.txt`:

- Served at root (`/robots.txt`)
- Sensitive paths (admin, API, internal tools) excluded via `Disallow`
- Versioned in the repository — no manual production changes
- AI crawlers (`GPTBot`, `CCBot`, `anthropic-ai`) explicitly blocked

Example (restrictive):

```text
User-agent: *
Disallow: /admin
Disallow: /api/
Disallow: /internal/

User-agent: GPTBot
Disallow: /

User-agent: CCBot
Disallow: /

Sitemap: https://example.com/sitemap.xml
```

> `robots.txt` is **not a security mechanism** — sensitive endpoints must additionally be protected by auth and access control.

---

## 9. Database & Migrations

> Applies only if the repo uses a DB.

- Schema changes exclusively via migrations
- Migrations are versioned, reproducible, and ideally rollbackable
- No manual DB hotfixes in production

---

## 10. Logging & Health

> Healthcheck applies only to services.

- Logs structured or unambiguously parseable
- Log level consistent (`ERROR/WARN/INFO/DEBUG`), production default `INFO`
- Healthcheck endpoint present (`/health` or `/healthz`)
- Healthcheck is fast and without heavy queries

---

## 10a. Sync Cadence with External Services

> Applies when this repo polls data from an external service (e.g. FreshRSS via GReader API).

- **Align poll interval with the source:** Sync interval must not be shorter than the update cadence of the upstream service. Shorter intervals only generate idle load + unnecessary API load.
- **Time offset:** When the upstream service works at fixed times (e.g. FreshRSS cron), set your own sync via cron expression to run a few minutes after the upstream fetch.
- **Configuration via ENV:** Sync schedules are configurable via ENV variable (not hardcoded) so adjustments are possible without rebuild.
- **Documentation requirement:** Every sync cadence is documented in `README.md` (ENV table) with justification — including a note on the upstream cadence it is aligned with.
- **Currently relevant:** FreshRSS `CRON_MIN=10,30,50` (3×/hour) → newsku default `FEED_SYNC_CRON=0 15,35,55 * * * *` (sync 5 min after each FreshRSS fetch).

---

## 11. Build & Deployment

### Custom Images (GitHub-hosted Runner)

- PR → merge to `main` → GitHub Actions builds the image on GitHub-hosted
  `ubuntu-latest`
- Push to GHCR (container tags: `latest` + SHA)
- Manual trigger via `workflow_dispatch` possible

### Deployment in docker-configs (GitOps)

- Deployment via docker-configs via Portainer GitOps (polling)
- Renovate creates PRs for third-party image updates → merge → Portainer redeploy
- No manual manipulation of deployments

### Rollback

- Rollback by reverting to previous GHCR image (SHA tag) in docker-configs repo
- Then redeploy and post-check

---

## 12. Definition of Done

A change is "done" when:

- Code implemented
- Tests green **locally** — CI runs them since 2026-08-26, but non-blocking (§5)
- Documentation updated (at minimum README, if affected)
- `CHANGELOG.md` updated (entry under `[Unreleased]` or under a date block — see §13)
- PR reviewed and merged
- **If image-based:** CI image built & available (GHCR), deployment triggered/completed
- **If release-based (libraries):** Release/tag built (only if the repo works this way)
- Post-check successful (health/login/version visible, if relevant)

---

## 13. Documentation Requirements

For every change that can go to production:

- Check/update README
- Changes described in a traceable manner in the PR
- **`CHANGELOG.md` updated** (see rules below)

### CHANGELOG.md (mandatory)

- **Every PR that lands on `main` MUST update `CHANGELOG.md`.**
- Add the entry under `## [Unreleased]` while the PR is open. On merge, either
  the PR itself or a follow-up housekeeping PR moves the `[Unreleased]` items
  into a dated block `## [YYYY-MM-DD]` (the merge date on `main`).
- Format follows [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/)
  with the categories **Added / Changed / Fixed / Security / Removed /
  Deprecated / Docs / Chore**.
- Each entry: short imperative description plus PR number in parentheses, e.g.
  `- Guard against empty feeds list in getPublicItems (#103)`.
- Pure refactors / whitespace-only / merge commits may be omitted.
- **No SemVer / no Git tags** — sections are date-grouped (see §4, §11).

---

## 13a. Doku-Hygiene

Doku veraltet an drei Stellen, und alle drei sind Aussagen, die nichts
nachrechnet: die **Kopie** (eine abgeleitete Seite wiederholt einen Fakt,
dessen Heimat woanders liegt), die **Sollens-Regel** (ein Regelwerk
behauptet eine Praxis, die so nicht gelebt wird) und die **handgepflegte
Aufzählung** (eine Tabelle spiegelt eine Menge aus dem Code).

Verbindlich vor Doku-Änderungen und bei jedem Aufräum-Durchgang: Notiz
**„Behauptungen, die niemand prüft"** im Todoteck-Projekt `llm-wiki`
(per `search`/`get_note`) — Gegenmittel je Sorte und Prüfliste.

Kurzfassung für dieses Repo:

- Eine Regel hier beschreibt, was **tatsächlich passiert**. Weicht sie von
  der Praxis ab, wird die Regel korrigiert — nicht die Praxis behauptet.
- Was sich aus dem Code aufzählen lässt (Modul-, Route-, Tabellenlisten,
  Verzeichnisbäume), gehört in einen Test, nicht in Prosa.
- Status („X von Y umgesetzt", „noch kein PR") gehört nach Todoteck oder in
  git — nicht in eine Datei, die beim Erledigen niemand anfasst.

---

## 14. README Structure (Template)

Every `README.md` in this repository follows this structure. Sections that do not apply are omitted — the order remains the same.

### Principles for READMEs

- **English** — all READMEs in English
- **Self-explanatory** — setup & operation must be possible without additional documentation
- **No filler** — every section has a clear purpose
- **Tables > prose**
- **ASCII diagrams > no diagrams** — no external images

### Mandatory Structure

| # | Section | Required | Condition for Optional |
|---|---------|---------|------------------------|
| 1 | Header with badges | **Yes** | — |
| 2 | User interface | No | Only for apps with UI |
| 3 | Feature overview | **Yes** | — |
| 4 | Architecture | **Yes** | — |
| 5 | Prerequisites | **Yes** | — |
| 6 | Installation / Quick start | **Yes** | — |
| 7 | Reverse proxy setup | No | Only for special proxy config |
| 8 | Configuration | **Yes** | — |
| 9 | API reference | No | Required for own APIs |
| 10 | Database schema | No | Recommended for own DBs |
| 11 | Security aspects | **Yes** | — |
| 12 | Technology stack | **Yes** | — |
| 13 | Project structure | No | Recommended for monorepos |
| 14 | Development | **Yes** | — |
| 15 | Versioning | No | Recommended |
| 16 | License | **Yes** | — |

---

## 15. Design System

Three homes, no fourth:

- **Token values and their rationale** — [DESIGN.md](DESIGN.md). Code-bound: the
  importance colours, breakpoints and component tokens are cited from there.
- **Flutter/M3 implementation patterns** — [docs/frontend-patterns.md](docs/frontend-patterns.md)
  (routing, BLoC, services, styling).
- **What holds across all Fauteck applications** — the wiki note
  „Fauteck Design-System (geteilt)" in the Todoteck project `llm-wiki`.

> Until 2026-08-26 a `docs/design-system.md` sat beside these, labelled „Legacy"
> by both DESIGN.md and this file. It had zero code references and repeated what
> the other two already say — typography, colours, breakpoints, icons from
> DESIGN.md, M3 styling from frontend-patterns.md. Removed under §13a.


## Compatibility with Other AI Tools

This file is named `CLAUDE.md` and is automatically recognised by Claude Code.

For other tools:

| Tool | Expected Path |
|---|---|
| Claude Code | `CLAUDE.md` (repository root) ✅ |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Cursor | `.cursor/rules` or `.cursorrules` |
| Windsurf | `.windsurfrules` |
| Cline | `.clinerules` |

Recommendation: Create symlinks or copies of `CLAUDE.md` at the respective paths
so all tools use the same rules.
