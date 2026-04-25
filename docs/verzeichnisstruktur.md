# Directory Structure

← [Back to Index](../CLAUDE.md)

---

## Root

```
/home/user/newsku/
├── CLAUDE.md                          # AI development rules + documentation index
├── DESIGN.md                          # Design system (tokens, colours, typography, motion)
├── README.md                          # Project documentation (features, setup)
├── pom.xml                            # Maven build configuration
├── .env.example                       # Environment variable template
├── docker-compose.yml                 # Docker stack (app + PostgreSQL)
├── Makefile                           # Documentation build (mkdocs)
├── shell.nix                          # Nix development environment (JDK 25, Maven, Python)
├── LICENSE
├── .github/
│   └── workflows/
│       └── build-docker.yml           # CI/CD: build JAR + Docker image to GHCR
├── docker/
│   ├── Dockerfile                     # Production Docker image (Amazon Corretto 25)
│   └── run.sh                         # JVM startup script (RAM limits)
├── docs/                              # AI-optimised development documentation (English)
│   ├── architektur.md
│   ├── verzeichnisstruktur.md         # (this file)
│   ├── api-patterns.md
│   ├── frontend-patterns.md
│   ├── datenbank.md
│   ├── entwicklung.md
│   ├── code-konventionen.md
│   ├── testing.md
│   ├── haeufige-aufgaben.md
│   ├── design-system.md
│   ├── issue-analyse.md
│   └── assets/                        # Screenshots and logos
├── mkdocs/                            # Public documentation website
│   ├── mkdocs.yml
│   ├── docs/
│   │   ├── index.md
│   │   ├── 1-installation.md
│   │   ├── 2-configuration.md
│   │   ├── 3-API.md
│   │   └── 4-UserManual.md
│   └── requirements.txt               # Python dependencies (mkdocs plugins)
└── src/
    └── main/
        ├── java/                      # Spring Boot backend (Java 25)
        ├── resources/                 # Configuration + migrations
        └── app/                       # Flutter app (Web + Android)
```

---

## Backend: `src/main/java/com/github/lamarios/newsku/`

```
src/main/java/com/github/lamarios/newsku/
├── Application.java                   # Spring Boot entry point
├── Config.java                        # Application configuration (beans, security)
├── Constants.java                     # Global constants
├── controllers/
│   ├── ClickController.java           # GET/POST /api/clicks — click tracking
│   ├── ConfigController.java          # GET /api/config — application configuration
│   ├── FeedCategoryController.java    # CRUD /api/feed-categories
│   ├── FeedController.java            # CRUD /api/feeds — feed management
│   ├── FeedErrorController.java       # GET /api/feed-errors — error log
│   ├── FeedItemController.java        # GET/PATCH /api/feed-items — articles
│   ├── LayoutController.java          # CRUD /api/layouts — layout blocks
│   ├── ResetPasswordController.java   # POST /api/reset-password
│   ├── SearchController.java          # GET /api/search
│   ├── SignUpController.java          # POST /api/signup
│   ├── StaticContentController.java   # Serve Flutter web build
│   └── UserController.java            # Auth: login, OIDC, profile, settings
├── services/
│   ├── ClickService.java              # Manage click statistics
│   ├── EmailDigestService.java        # Email digest sending (scheduler)
│   ├── EmailService.java              # Email interface
│   ├── EmailServiceImpl.java          # Simple Java Mail implementation
│   ├── FeedCategoriesService.java     # Feed category business logic
│   ├── FeedErrorService.java          # Log feed errors
│   ├── FeedItemService.java           # Load, filter, mark feed items as read
│   ├── FeedService.java               # Fetch RSS, persist items, trigger LLM
│   ├── LayoutService.java             # Manage layout blocks
│   ├── OidcService.java               # Validate OpenID Connect tokens
│   ├── OpenaiService.java             # LLM ranking interface
│   ├── OpenaiServiceImpl.java         # OpenAI SDK implementation
│   ├── ResetPasswordService.java      # Password reset logic
│   ├── ScheduleService.java           # Scheduled tasks (feed refresh, digest)
│   └── UserService.java               # Manage users, auth
├── persistence/
│   ├── entities/
│   │   ├── Feed.java                  # JPA entity: feeds
│   │   ├── FeedCategory.java          # JPA entity: feed_categories
│   │   ├── FeedError.java             # JPA entity: feed_errors
│   │   ├── FeedItem.java              # JPA entity: feed_items
│   │   ├── LayoutBlock.java           # JPA entity: layout_blocks
│   │   ├── User.java                  # JPA entity: users
│   │   └── ...                        # further entities
│   └── repositories/
│       ├── FeedRepository.java        # Spring Data JPA repository
│       ├── FeedItemRepository.java
│       ├── UserRepository.java
│       └── ...                        # further repositories
├── security/
│   ├── JwtAuthFilter.java             # JWT validation in filter chain
│   ├── JwtService.java                # Generate/validate JWT (JJWT)
│   └── ...                            # further security classes
├── errors/
│   └── ...                            # Custom exceptions + GlobalExceptionHandler
└── utils/
    └── ...                            # HTML, image, transaction helpers
```

---

## Resources: `src/main/resources/`

```
src/main/resources/
├── application.yml                    # Spring Boot configuration (DB, Flyway, port)
├── db/
│   └── migration/
│       ├── V1__initial_schema.sql     # Initial schema
│       ├── V2__oidc.sql               # OIDC support
│       ├── V3__*.sql
│       ├── ...
│       └── V16__feed_categories.sql   # Feed categories (latest migration)
└── templates/
    └── email/
        ├── digest.ftl                 # Freemarker: email digest template
        └── reset-password.ftl         # Freemarker: password reset template
```

---

## Flutter Frontend: `src/main/app/`

```
src/main/app/
├── pubspec.yaml                       # Dart/Flutter dependencies
├── analysis_options.yaml              # Dart linter configuration
├── l10n.yaml                          # Internationalisation configuration
├── lib/
│   ├── main.dart                      # Flutter entry point
│   ├── router.dart                    # auto_route routing definition
│   ├── router.gr.dart                 # Generated routing (auto_route)
│   ├── base_service.dart              # Base HTTP service
│   ├── feed/                          # Feed module (models, services, views)
│   ├── user/                          # User/auth module
│   ├── config/                        # Configuration module
│   ├── settings/                      # Settings UI
│   ├── layouts/                       # Layout customisation
│   ├── stats/                         # Statistics module
│   ├── home/                          # Home screen
│   ├── identity/                      # Login/logout state
│   └── utils/                         # Shared helpers
├── web/
│   ├── index.html                     # PWA entry point
│   ├── manifest.json                  # PWA manifest
│   ├── redirect.html
│   └── icons/                         # PWA icons (192x192, 512x512)
├── android/                           # Native Android project (Gradle)
├── ios/                               # iOS project files
├── linux/                             # Linux desktop build
├── macos/                             # macOS desktop build
└── test/                              # Flutter unit and widget tests
```

---

## Related Documents

- [docs/api-patterns.md](api-patterns.md) — Controller structure in detail
- [docs/frontend-patterns.md](frontend-patterns.md) — Flutter modules and patterns
- [docs/datenbank.md](datenbank.md) — Schema reference and migrations
