# API-Patterns

← [Zurueck zum Index](../CLAUDE.md)

---

## Uebersicht

Die API folgt einem klassischen Spring Boot Schicht-Muster:

```
Controller (HTTP-Handler)
  │
  ├─ Spring Validation (@Valid, @RequestBody)
  ├─ Spring Security (@PreAuthorize / SecurityContext)
  │
  └─ Service (Geschaeftslogik)
       │
       └─ JPA Repository (Datenbankzugriff via Spring Data)
```

API-Dokumentation (Swagger UI) erreichbar unter: `/swagger-ui.html`

---

## Controller-Uebersicht

Alle Controller liegen in `src/main/java/com/github/lamarios/newsku/controllers/`:

| Klasse | Prefix | Beschreibung |
|--------|--------|-------------|
| `UserController` | `/api/users` | Login, OIDC-Auth, Profil, Einstellungen |
| `SignUpController` | `/api/signup` | Benutzerregistrierung (nur wenn `ALLOW_SIGNUP=1`) |
| `ResetPasswordController` | `/api/reset-password` | Passwort-Reset via E-Mail |
| `FeedController` | `/api/feeds` | CRUD RSS-Feeds |
| `FeedItemController` | `/api/feed-items` | Feed-Beitraege abrufen, als gelesen markieren |
| `FeedCategoryController` | `/api/feed-categories` | CRUD Feed-Kategorien |
| `FeedErrorController` | `/api/feed-errors` | Feed-Fehlerprotokoll abrufen |
| `LayoutController` | `/api/layouts` | CRUD Layout-Bloecke (Startseiten-Konfiguration) |
| `ClickController` | `/api/clicks` | Klick-Tracking fuer Statistiken |
| `SearchController` | `/api/search` | Volltextsuche ueber Feed-Beitraege |
| `ConfigController` | `/api/config` | Anwendungskonfiguration (Signup erlaubt?) |
| `StaticContentController` | `/**` | Flutter Web Build ausliefern |

---

## Controller-Pattern

Spring Boot REST Controller mit JWT-Absicherung:

```java
// src/main/java/com/github/lamarios/newsku/controllers/FeedController.java

@RestController
@RequestMapping("/api/feeds")
public class FeedController {

    private final FeedService feedService;

    public FeedController(FeedService feedService) {
        this.feedService = feedService;
    }

    // Alle Feeds des authentifizierten Benutzers
    @GetMapping
    public List<Feed> getFeeds(Authentication auth) {
        String userId = auth.getName();
        return feedService.getFeedsForUser(userId);
    }

    // Neuen Feed erstellen
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Feed createFeed(@RequestBody @Valid CreateFeedRequest request, Authentication auth) {
        String userId = auth.getName();
        return feedService.createFeed(userId, request);
    }

    // Feed aktualisieren
    @PutMapping("/{id}")
    public Feed updateFeed(@PathVariable String id,
                           @RequestBody @Valid UpdateFeedRequest request,
                           Authentication auth) {
        String userId = auth.getName();
        return feedService.updateFeed(userId, id, request);
    }

    // Feed loeschen
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteFeed(@PathVariable String id, Authentication auth) {
        String userId = auth.getName();
        feedService.deleteFeed(userId, id);
    }
}
```

---

## Authentifizierung

Geschuetzte Endpunkte werden via Spring Security + JWT-Filter abgesichert.
Der `JwtAuthFilter` setzt den `SecurityContext` bei gueltigem Bearer-Token.

Der authentifizierte Benutzer ist in `Authentication auth` verfuegbar:

```java
// Benutzer-ID aus JWT-Subject holen
String userId = auth.getName();

// Alternativ: Vollstaendiges Principal-Objekt
UserDetails user = (UserDetails) auth.getPrincipal();
```

Fuer OIDC-Authentifizierung: `OidcService` validiert den OIDC-Token und gibt den lokalen Benutzer zurueck.

---

## Validierung

Request-Bodies werden via Jakarta Validation validiert:

```java
// Request DTO
public class CreateFeedRequest {
    @NotBlank
    @URL
    private String feedUrl;

    @NotBlank
    @Size(max = 255)
    private String title;

    // Getter/Setter oder Lombok @Data
}

// Im Controller
@PostMapping
public Feed createFeed(@RequestBody @Valid CreateFeedRequest request, ...) {
    // Bei Validierungsfehler: 400 Bad Request (automatisch durch Spring)
}
```

---

## Service-Layer

Services kapseln die Geschaeftslogik und Datenbank-Zugriffe:

| Klasse | Wichtige Methoden |
|--------|------------------|
| `FeedService` | `getFeedsForUser()`, `createFeed()`, `refreshFeed()`, `deleteFeed()` |
| `FeedItemService` | `getItemsForUser()`, `markAsRead()`, `getUnreadCount()` |
| `UserService` | `login()`, `createUser()`, `updateSettings()` |
| `OpenaiServiceImpl` | `rankItems(userId, items)` → importance_score |
| `ScheduleService` | `refreshAllFeeds()`, `sendDigests()` (Scheduled) |
| `EmailServiceImpl` | `sendDigest()`, `sendPasswordReset()` |
| `ClickService` | `trackClick()`, `getStats()` |

### Beispiel: Service-Implementierung

```java
// src/main/java/com/github/lamarios/newsku/services/FeedService.java

@Service
@Transactional
public class FeedService {

    private final FeedRepository feedRepository;
    private final FeedItemRepository feedItemRepository;
    private final OpenaiService openaiService;

    public FeedService(FeedRepository feedRepository,
                       FeedItemRepository feedItemRepository,
                       OpenaiService openaiService) {
        this.feedRepository = feedRepository;
        this.feedItemRepository = feedItemRepository;
        this.openaiService = openaiService;
    }

    public List<Feed> getFeedsForUser(String userId) {
        return feedRepository.findByUserId(userId);
    }

    public Feed createFeed(String userId, CreateFeedRequest request) {
        Feed feed = new Feed();
        feed.setUserId(userId);
        feed.setFeedUrl(request.getFeedUrl());
        feed.setTitle(request.getTitle());
        return feedRepository.save(feed);
    }
}
```

---

## JPA Repositories

Repositories erweitern `JpaRepository` und koennen Spring Data Query-Methods nutzen:

```java
// src/main/java/com/github/lamarios/newsku/persistence/repositories/FeedRepository.java

@Repository
public interface FeedRepository extends JpaRepository<Feed, String> {
    List<Feed> findByUserId(String userId);
    Optional<Feed> findByIdAndUserId(String id, String userId);
}
```

---

## HTTP-Status-Codes

| Code | Verwendung |
|------|-----------|
| `200` | Erfolg (GET, PUT) |
| `201` | Erstellt (POST) |
| `204` | Kein Inhalt (DELETE) |
| `400` | Validierungsfehler |
| `401` | Nicht authentifiziert |
| `403` | Keine Berechtigung |
| `404` | Nicht gefunden |
| `503` | Health Check degraded |

---

## Fehlerbehandlung

Globale Fehlerbehandlung via `@ControllerAdvice`:

```java
// In errors/ Package
@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(EntityNotFoundException ex) {
        return ResponseEntity.status(404).body(new ErrorResponse(ex.getMessage()));
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ErrorResponse> handleForbidden(AccessDeniedException ex) {
        return ResponseEntity.status(403).body(new ErrorResponse("Zugriff verweigert"));
    }
}
```

---

## How-To: Neuen Endpunkt hinzufuegen

1. **Controller erstellen** (oder bestehenden erweitern):

```java
// src/main/java/com/github/lamarios/newsku/controllers/MeinController.java
@RestController
@RequestMapping("/api/mein-resource")
public class MeinController {
    private final MeinService meinService;

    @GetMapping
    public List<MeinDto> getAll(Authentication auth) {
        return meinService.getAll(auth.getName());
    }
}
```

2. **Service erstellen** in `services/`:

```java
@Service
@Transactional
public class MeinService {
    // Logik + Repository-Aufrufe
}
```

3. **Entity + Repository** in `persistence/` anlegen (falls neue Tabelle)

4. **Flyway-Migration** in `src/main/resources/db/migration/` hinzufuegen

---

## Verwandte Dokumente

- [docs/architektur.md](architektur.md) — Request-Flow, Auth-Flow
- [docs/datenbank.md](datenbank.md) — JPA Entities, Flyway-Schema
- [docs/haeufige-aufgaben.md](haeufige-aufgaben.md) — End-to-End Feature-Guide
