# Verzeichnisstruktur

← [Zurueck zum Index](../CLAUDE.md)

---

## Root

```
/home/user/newsku/
├── CLAUDE.md                          # KI-Entwicklungsregeln + Dokumentations-Index
├── README.md                          # Projekt-Dokumentation (Features, Setup)
├── pom.xml                            # Maven Build-Konfiguration
├── .env.example                       # Umgebungsvariablen-Vorlage
├── docker-compose.yml                 # Docker-Stack (App + PostgreSQL)
├── Makefile                           # Dokumentations-Build (mkdocs)
├── shell.nix                          # Nix Entwicklungsumgebung (JDK 25, Maven, Python)
├── LICENSE
├── .github/
│   └── workflows/
│       └── build-docker.yml           # CI/CD: JAR bauen + Docker-Image nach GHCR
├── docker/
│   ├── Dockerfile                     # Production Docker Image (Amazon Corretto 25)
│   └── run.sh                         # JVM-Startskript (RAM-Limits)
├── docs/                              # KI-optimierte Entwicklungsdokumentation (Deutsch)
│   ├── architektur.md
│   ├── verzeichnisstruktur.md         # (diese Datei)
│   ├── api-patterns.md
│   ├── frontend-patterns.md
│   ├── datenbank.md
│   ├── entwicklung.md
│   ├── code-konventionen.md
│   ├── testing.md
│   ├── haeufige-aufgaben.md
│   ├── design-system.md
│   ├── issue-analyse.md
│   └── assets/                        # Screenshots und Logos
├── mkdocs/                            # Oeffentliche Dokumentationsseite
│   ├── mkdocs.yml
│   ├── docs/
│   │   ├── index.md
│   │   ├── 1-installation.md
│   │   ├── 2-configuration.md
│   │   ├── 3-API.md
│   │   └── 4-UserManual.md
│   └── requirements.txt               # Python-Abhaengigkeiten (mkdocs-Plugins)
└── src/
    └── main/
        ├── java/                      # Spring Boot Backend (Java 25)
        ├── resources/                 # Konfiguration + Migrationen
        └── app/                       # Flutter App (Web + Android)
```

---

## Backend: `src/main/java/com/github/lamarios/newsku/`

```
src/main/java/com/github/lamarios/newsku/
├── Application.java                   # Spring Boot Einstiegspunkt
├── Config.java                        # Anwendungskonfiguration (Beans, Security)
├── Constants.java                     # Globale Konstanten
├── controllers/
│   ├── ClickController.java           # GET/POST /api/clicks – Klick-Tracking
│   ├── ConfigController.java          # GET /api/config – Anwendungskonfiguration
│   ├── FeedCategoryController.java    # CRUD /api/feed-categories
│   ├── FeedController.java            # CRUD /api/feeds – Feed-Verwaltung
│   ├── FeedErrorController.java       # GET /api/feed-errors – Fehlerprotokoll
│   ├── FeedItemController.java        # GET/PATCH /api/feed-items – Beitraege
│   ├── LayoutController.java          # CRUD /api/layouts – Layout-Bloecke
│   ├── ResetPasswordController.java   # POST /api/reset-password
│   ├── SearchController.java          # GET /api/search
│   ├── SignUpController.java          # POST /api/signup
│   ├── StaticContentController.java   # Ausliefern des Flutter Web Builds
│   └── UserController.java            # Auth: Login, OIDC, Profil, Einstellungen
├── services/
│   ├── ClickService.java              # Klick-Statistiken verwalten
│   ├── EmailDigestService.java        # E-Mail Digest Versand (Scheduler)
│   ├── EmailService.java              # E-Mail Interface
│   ├── EmailServiceImpl.java          # Simple Java Mail Implementierung
│   ├── FeedCategoriesService.java     # Feed-Kategorien Geschaeftslogik
│   ├── FeedErrorService.java          # Feed-Fehler protokollieren
│   ├── FeedItemService.java           # FeedItems laden, filtern, als gelesen markieren
│   ├── FeedService.java               # RSS abrufen, Items persistieren, LLM triggern
│   ├── LayoutService.java             # Layout-Bloecke verwalten
│   ├── OidcService.java               # OpenID Connect Token validieren
│   ├── OpenaiService.java             # LLM Ranking Interface
│   ├── OpenaiServiceImpl.java         # OpenAI SDK Implementierung
│   ├── ResetPasswordService.java      # Passwort-Reset Logik
│   ├── ScheduleService.java           # Scheduled Tasks (Feed-Refresh, Digest)
│   └── UserService.java               # Benutzer verwalten, Auth
├── persistence/
│   ├── entities/
│   │   ├── Feed.java                  # JPA Entity: feeds
│   │   ├── FeedCategory.java          # JPA Entity: feed_categories
│   │   ├── FeedError.java             # JPA Entity: feed_errors
│   │   ├── FeedItem.java              # JPA Entity: feed_items
│   │   ├── LayoutBlock.java           # JPA Entity: layout_blocks
│   │   ├── User.java                  # JPA Entity: users
│   │   └── ...                        # weitere Entities
│   └── repositories/
│       ├── FeedRepository.java        # Spring Data JPA Repository
│       ├── FeedItemRepository.java
│       ├── UserRepository.java
│       └── ...                        # weitere Repositories
├── security/
│   ├── JwtAuthFilter.java             # JWT-Validierung in der Filter-Chain
│   ├── JwtService.java                # JWT erzeugen/validieren (JJWT)
│   └── ...                            # weitere Security-Klassen
├── errors/
│   └── ...                            # Custom Exceptions + GlobalExceptionHandler
└── utils/
    └── ...                            # HTML-, Image-, Transaktions-Hilfklassen
```

---

## Ressourcen: `src/main/resources/`

```
src/main/resources/
├── application.yml                    # Spring Boot Konfiguration (DB, Flyway, Port)
├── db/
│   └── migration/
│       ├── V1__initial_schema.sql     # Initiales Schema
│       ├── V2__oidc.sql               # OIDC-Unterstuetzung
│       ├── V3__*.sql
│       ├── ...
│       └── V16__feed_categories.sql   # Feed-Kategorien (neueste Migration)
└── templates/
    └── email/
        ├── digest.ftl                 # Freemarker: E-Mail Digest Template
        └── reset-password.ftl         # Freemarker: Passwort-Reset Template
```

---

## Flutter Frontend: `src/main/app/`

```
src/main/app/
├── pubspec.yaml                       # Dart/Flutter Abhaengigkeiten
├── analysis_options.yaml              # Dart Linter-Konfiguration
├── l10n.yaml                          # Internationalisierungs-Konfiguration
├── lib/
│   ├── main.dart                      # Flutter Einstiegspunkt
│   ├── router.dart                    # auto_route Routing-Definition
│   ├── router.gr.dart                 # Generiertes Routing (auto_route)
│   ├── base_service.dart              # Basis HTTP-Service
│   ├── feed/                          # Feed-Modul (Modelle, Services, Views)
│   ├── user/                          # Benutzer/Auth-Modul
│   ├── config/                        # Konfigurations-Modul
│   ├── settings/                      # Einstellungs-UI
│   ├── layouts/                       # Layout-Anpassung
│   ├── stats/                         # Statistik-Modul
│   ├── home/                          # Startseite
│   ├── identity/                      # Login/Logout-State
│   └── utils/                         # Gemeinsame Hilfsfunktionen
├── web/
│   ├── index.html                     # PWA Einstiegspunkt
│   ├── manifest.json                  # PWA Manifest
│   ├── redirect.html
│   └── icons/                         # PWA Icons (192x192, 512x512)
├── android/                           # Native Android-Projekt (Gradle)
├── ios/                               # iOS-Projektdateien
├── linux/                             # Linux Desktop Build
├── macos/                             # macOS Desktop Build
└── test/                              # Flutter Unit- und Widget-Tests
```

---

## Verwandte Dokumente

- [docs/api-patterns.md](api-patterns.md) — Controller-Struktur im Detail
- [docs/frontend-patterns.md](frontend-patterns.md) — Flutter-Module und -Patterns
- [docs/datenbank.md](datenbank.md) — Schema-Referenz und Migrationen
