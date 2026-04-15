# CLAUDE.md — Verbindliche Regeln für KI-gestützte Entwicklung

> **Geltung:** Dieses Dokument ist die **alleinstehende, verbindliche Regelbasis** dieses Repositories.
> Es ersetzt zusätzliche KI-/Design-/README-Regeldateien. Wenn einzelne Kapitel für dieses Repo nicht zutreffen (z. B. Web-spezifische Regeln), werden sie **ignoriert**, ohne dass weitere Dateien benötigt werden.

---

## Dokumentations-Index

| Dokument | Inhalt |
|----------|--------|
| [README.md](README.md) | Feature-Übersicht, Architektur-Diagramm, API-Referenz |
| [docs/architektur.md](docs/architektur.md) | Tech Stack, Datenmodelle, Request-Flow, Auth |
| [docs/verzeichnisstruktur.md](docs/verzeichnisstruktur.md) | Kompletter Dateibaum mit absoluten Pfaden |
| [docs/api-patterns.md](docs/api-patterns.md) | Fastify-Routen, Services, Plugins, Validierung |
| [docs/frontend-patterns.md](docs/frontend-patterns.md) | React-Patterns, Zustand, Seiten, Komponenten |
| [docs/datenbank.md](docs/datenbank.md) | Drizzle-Schema, Migrationen, Beziehungen |
| [docs/entwicklung.md](docs/entwicklung.md) | Setup, Dev-Server, Feature-Walkthrough |
| [docs/code-konventionen.md](docs/code-konventionen.md) | Stil-Guide, Naming, TypeScript-Patterns |
| [docs/testing.md](docs/testing.md) | Vitest, Testorganisation, Mocking |
| [docs/haeufige-aufgaben.md](docs/haeufige-aufgaben.md) | How-To-Guides für typische Aufgaben |
| [docs/design-system.md](docs/design-system.md) | Fauteck Design System (Tokens, Komponenten) |

---

## Inhaltsverzeichnis

1. [Grundprinzipien](#1-grundprinzipien)
2. [Erlaubt / Nicht erlaubt](#2-erlaubt--nicht-erlaubt)
3. [Branching, Merge, Reviews](#3-branching-merge-reviews)
4. [Image-Builds (Local Runner)](#4-image-builds-local-runner)
5. [Qualitätsanforderungen (Gates)](#5-qualitätsanforderungen-gates)
6. [Security & Secrets](#6-security--secrets)
7. [OWASP Top 10](#7-owasp-top-10)
8. [robots.txt](#8-robotstxt)
9. [Datenbank & Migrationen](#9-datenbank--migrationen)
10. [Logging & Health](#10-logging--health)
11. [Build & Deployment](#11-build--deployment)
12. [Definition of Done](#12-definition-of-done)
13. [Dokumentationspflicht](#13-dokumentationspflicht)
14. [README-Struktur (Vorlage)](#14-readme-struktur-vorlage)
15. [Design System](#15-design-system)

---

## 1. Grundprinzipien

- **GitOps first**: Produktion wird ausschließlich über versionierte Images und deklarative Infra-Rollouts aktualisiert.
- **Keine Runtime-Hotfixes**: Fehlerbehebung erfolgt über Code-Change → neues Image → Deployment.
- **Reproduzierbarkeit**: Ein **Git-Tag (falls genutzt)** muss stets den gleichen Build ergeben (CI/CD als Source of Truth).

---

## 2. Erlaubt / Nicht erlaubt

### Die KI darf

- Code ändern und refactoren (im Rahmen bestehender Architektur)
- Dateien erstellen/ändern (inkl. Tests und Doku)
- Build-/CI-Konfiguration anpassen (wenn notwendig und begründet)
- CI/CD-Workflows für Local Runner (Self-Hosted Runner) anpassen

### Die KI darf NICHT

- `docker compose up` als **produktiven Betrieb** vorschlagen
- Container direkt manipulieren (exec, hotpatch, manuelle Änderungen)
- Änderungen direkt in Portainer vornehmen
- Manuelles `docker build` oder `docker push` **für Produktion** empfehlen
- Infrastruktur-Annahmen treffen (Host-Pfade, Volumes, Netzwerke), wenn nicht explizit gegeben

> Hinweis: `docker compose` kann für **lokale Entwicklung** sinnvoll sein, ist aber **nicht** der produktive Betriebs-/Deploy-Weg.

---

## 3. Branching, Merge, Reviews

- Entwicklung auf Feature-/Fix-Branches
- Merge via Pull Request
- `main` ist releasefähig/produktionsnah und geschützt
- CI muss grün sein, bevor gemerged wird

Empfohlene Branch-Benennung: `feature/...`, `fix/...`, `chore/...`

PR enthält: Zweck, Scope, Testhinweise, mögliche Breaking Changes

---

## 4. Image-Builds (Local Runner)

Custom Images werden über GitHub Actions mit Self-Hosted Runner gebaut.

- **Keine GitHub-Releases / kein SemVer / keine Git-Tags** als „Release-Mechanik“ für Custom Images
- Build-Trigger: Push auf `main` (nach PR-Merge) oder manuell via `workflow_dispatch`
- Images erhalten **Container-Tags** `latest` + kurzer SHA-Commit-Hash
- Registry: GHCR (`ghcr.io/<owner>/<image>`)
- Jeder Merge in `main` erzeugt automatisch ein neues Image

---

## 5. Qualitätsanforderungen (Gates)

Vor einem Merge in `main` muss gelten:

- Tests laufen (Unit/Integration sofern vorhanden)
- Linting/Formatting ist konsistent
- Keine Debug-Ausgaben / temporäre Workarounds
- Keine ungenutzten ENV-Variablen
- Build in CI erfolgreich und reproduzierbar

Empfohlene CI-Jobs: `lint`, `test`, `build`, optional `security` (Dependency/Secret Scan)

---

## 6. Security & Secrets

- Keine Secrets im Code oder Repo
- Keine Tokens/Keys in Logs
- `.env` niemals committen, stattdessen `.env.example`
- Secrets ausschließlich über ENV/Secret-Management
- Kein „Default Admin Password" in produktiven Images

---

## 7. OWASP Top 10

Beim Vibecoding **müssen** die OWASP Top 10 berücksichtigt werden:
https://owasp.org/Top10/2025/

**Regel:** Wenn dieses Repo Web-/API-Endpoints bereitstellt, gilt OWASP als Mindestcheckliste. Wenn nicht (z. B. CLI/Lib), gilt OWASP sinngemäß (Input-Validation, Supply Chain, Secrets, Logging).

---

## 8. robots.txt

> Gilt nur für öffentlich erreichbare Webapplikationen. Für Libraries/CLIs ignorieren.

Jede öffentlich erreichbare Webapplikation **muss** eine `robots.txt` bereitstellen:

- Auslieferung im Root (`/robots.txt`)
- Sensible Pfade (Admin, API, interne Tools) per `Disallow` ausschließen
- Versioniert im Repository — keine manuellen Änderungen in Produktion
- KI-Crawler (`GPTBot`, `CCBot`, `anthropic-ai`) gezielt blockieren

Beispiel (restriktiv):

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

> `robots.txt` ist **kein Sicherheitsmechanismus** — sensible Endpunkte müssen zusätzlich durch Auth und Zugriffskontrolle geschützt sein.

---

## 9. Datenbank & Migrationen

> Gilt nur, wenn das Repo eine DB nutzt.

- Schema-Änderungen ausschließlich über Migrationen
- Migrationen sind versioniert, reproduzierbar und idealerweise rollbackbar
- Keine manuellen DB-Hotfixes in Produktion

---

## 10. Logging & Health

> Healthcheck gilt nur für Services.

- Logs strukturiert oder eindeutig parsebar
- Log-Level konsistent (`ERROR/WARN/INFO/DEBUG`), Produktion standardmäßig `INFO`
- Healthcheck-Endpunkt vorhanden (`/health` oder `/healthz`)
- Healthcheck ist schnell und ohne schwere Queries

---

## 11. Build & Deployment

### Custom Images (Local Runner)

- PR → Merge in `main` → GitHub Actions baut Image auf dem Self-Hosted Runner
- Push nach GHCR (Container-Tags: `latest` + SHA)
- Manueller Trigger via `workflow_dispatch` möglich

### Deployment in docker-configs (GitOps)

- Deployment über docker-configs via Portainer GitOps (Polling)
- Renovate erstellt PRs für Third-Party-Image-Updates → Merge → Portainer Redeploy
- Keine manuelle Manipulation an Deployments

### Rollback

- Rollback durch Rücksetzen auf vorheriges GHCR-Image (SHA-Tag) im docker-configs Repo
- Danach Redeploy und Nachkontrolle

---

## 12. Definition of Done

Eine Änderung ist „done", wenn:

- Code umgesetzt
- Tests grün
- Doku aktualisiert (mindestens README, falls betroffen)
- PR reviewed und gemerged
- **Wenn Image-basiert:** CI-Image gebaut & verfügbar (GHCR), Deployment angestoßen/erfolgt
- **Wenn Release-basiert (Libraries):** Release/Tag gebaut (nur wenn das Repo so arbeitet)
- Nachkontrolle erfolgreich (Health/Login/Version sichtbar, falls relevant)

---

## 13. Dokumentationspflicht

Bei jeder Änderung, die in Produktion gehen kann:

- README prüfen/aktualisieren
- Änderungen nachvollziehbar im PR beschreiben

---

## 14. README-Struktur (Vorlage)

Jede `README.md` in diesem Repository folgt dieser Gliederung. Abschnitte, die nicht zutreffen, werden weggelassen — die Reihenfolge bleibt gleich.

### Grundprinzipien für READMEs

- **Deutsch** — alle READMEs auf Deutsch
- **Selbsterklärend** — Setup & Betrieb müssen ohne Zusatzdoku möglich sein
- **Kein Fülltext** — jeder Abschnitt hat einen klaren Zweck
- **Tabellen > Fließtext**
- **ASCII-Diagramme > Keine Diagramme** — keine externen Bilder

### Verbindliche Gliederung

| # | Abschnitt | Pflicht | Bedingung für Optional |
|---|-----------|---------|------------------------|
| 1 | Header mit Badges | **Ja** | — |
| 2 | Benutzeroberfläche | Nein | Nur bei Apps mit UI |
| 3 | Feature-Übersicht | **Ja** | — |
| 4 | Architektur | **Ja** | — |
| 5 | Voraussetzungen | **Ja** | — |
| 6 | Installation / Schnellstart | **Ja** | — |
| 7 | Reverse-Proxy-Einrichtung | Nein | Nur bei spezieller Proxy-Config |
| 8 | Konfiguration | **Ja** | — |
| 9 | API-Referenz | Nein | Pflicht bei eigenen APIs |
| 10 | Datenbankschema | Nein | Empfohlen bei eigenen DBs |
| 11 | Sicherheitsaspekte | **Ja** | — |
| 12 | Technologie-Stack | **Ja** | — |
| 13 | Projektstruktur | Nein | Empfohlen bei Monorepos |
| 14 | Entwicklung | **Ja** | — |
| 15 | Versionierung | Nein | Empfohlen |
| 16 | Lizenz | **Ja** | — |

---

## 15. Design System

→ Ausgelagert nach [docs/design-system.md](docs/design-system.md)


## Kompatibilität mit anderen KI-Tools

Diese Datei heißt `CLAUDE.md` und wird von Claude Code automatisch erkannt.

Für andere Tools:

| Tool | Erwarteter Pfad |
|---|---|
| Claude Code | `CLAUDE.md` (Repository-Root) ✅ |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Cursor | `.cursor/rules` oder `.cursorrules` |
| Windsurf | `.windsurfrules` |
| Cline | `.clinerules` |

Empfehlung: Symlinks oder Kopien der `CLAUDE.md` unter den jeweiligen Pfaden anlegen, damit alle Tools dieselben Regeln verwenden.
