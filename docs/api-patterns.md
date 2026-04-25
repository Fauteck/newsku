# API Patterns

← [Back to Index](../CLAUDE.md)

---

## Overview

The API follows a classic Spring Boot layered pattern:

```
Controller (HTTP handler)
  │
  ├─ Spring Validation (@Valid, @RequestBody)
  ├─ Spring Security (@PreAuthorize / SecurityContext)
  │
  └─ Service (business logic)
       │
       └─ JPA Repository (database access via Spring Data)
```

API documentation (Swagger UI) available at: `/swagger-ui.html`

---

## Controller Overview

All controllers are in `src/main/java/com/github/lamarios/newsku/controllers/`:

| Class | Prefix | Description |
|-------|--------|-------------|
| `UserController` | `/api/users` | Login, OIDC auth, profile, settings |
| `SignUpController` | `/api/signup` | User registration (only when `ALLOW_SIGNUP=1`) |
| `ResetPasswordController` | `/api/reset-password` | Password reset via email |
| `FeedController` | `/api/feeds` | CRUD RSS feeds |
| `FeedItemController` | `/api/feed-items` | Retrieve feed articles, mark as read |
| `FeedCategoryController` | `/api/feed-categories` | CRUD feed categories |
| `FeedErrorController` | `/api/feed-errors` | Retrieve feed error log |
| `LayoutController` | `/api/layouts` | CRUD layout blocks (home page configuration) |
| `ClickController` | `/api/clicks` | Click tracking for statistics |
| `SearchController` | `/api/search` | Full-text search over feed articles |
| `ConfigController` | `/api/config` | Application configuration (signup allowed?) |
| `StaticContentController` | `/**` | Serve Flutter Web build |

---

## Controller Pattern

Spring Boot REST controller with JWT protection:

```java
// src/main/java/com/github/lamarios/newsku/controllers/FeedController.java

@RestController
@RequestMapping("/api/feeds")
public class FeedController {

    private final FeedService feedService;

    public FeedController(FeedService feedService) {
        this.feedService = feedService;
    }

    // All feeds for the authenticated user
    @GetMapping
    public List<Feed> getFeeds(Authentication auth) {
        String userId = auth.getName();
        return feedService.getFeedsForUser(userId);
    }

    // Create new feed
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Feed createFeed(@RequestBody @Valid CreateFeedRequest request, Authentication auth) {
        String userId = auth.getName();
        return feedService.createFeed(userId, request);
    }

    // Update feed
    @PutMapping("/{id}")
    public Feed updateFeed(@PathVariable String id,
                           @RequestBody @Valid UpdateFeedRequest request,
                           Authentication auth) {
        String userId = auth.getName();
        return feedService.updateFeed(userId, id, request);
    }

    // Delete feed
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteFeed(@PathVariable String id, Authentication auth) {
        String userId = auth.getName();
        feedService.deleteFeed(userId, id);
    }
}
```

---

## Authentication

Protected endpoints are secured via Spring Security + JWT filter.
`JwtAuthFilter` sets the `SecurityContext` for valid bearer tokens.

The authenticated user is available via `Authentication auth`:

```java
// Get user ID from JWT subject
String userId = auth.getName();

// Alternative: full principal object
UserDetails user = (UserDetails) auth.getPrincipal();
```

For OIDC authentication: `OidcService` validates the OIDC token and returns the local user.

---

## Validation

Request bodies are validated via Jakarta Validation:

```java
// Request DTO
public class CreateFeedRequest {
    @NotBlank
    @URL
    private String feedUrl;

    @NotBlank
    @Size(max = 255)
    private String title;

    // Getters/setters or Lombok @Data
}

// In the controller
@PostMapping
public Feed createFeed(@RequestBody @Valid CreateFeedRequest request, ...) {
    // On validation error: 400 Bad Request (automatic via Spring)
}
```

---

## Service Layer

Services encapsulate business logic and database access:

| Class | Key Methods |
|-------|------------|
| `FeedService` | `getFeedsForUser()`, `createFeed()`, `refreshFeed()`, `deleteFeed()` |
| `FeedItemService` | `getItemsForUser()`, `markAsRead()`, `getUnreadCount()` |
| `UserService` | `login()`, `createUser()`, `updateSettings()` |
| `OpenaiServiceImpl` | `rankItems(userId, items)` → importance_score |
| `ScheduleService` | `refreshAllFeeds()`, `sendDigests()` (scheduled) |
| `EmailServiceImpl` | `sendDigest()`, `sendPasswordReset()` |
| `ClickService` | `trackClick()`, `getStats()` |

### Example: Service Implementation

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

Repositories extend `JpaRepository` and can use Spring Data query methods:

```java
// src/main/java/com/github/lamarios/newsku/persistence/repositories/FeedRepository.java

@Repository
public interface FeedRepository extends JpaRepository<Feed, String> {
    List<Feed> findByUserId(String userId);
    Optional<Feed> findByIdAndUserId(String id, String userId);
}
```

---

## HTTP Status Codes

| Code | Usage |
|------|-------|
| `200` | Success (GET, PUT) |
| `201` | Created (POST) |
| `204` | No content (DELETE) |
| `400` | Validation error |
| `401` | Not authenticated |
| `403` | Forbidden |
| `404` | Not found |
| `503` | Health check degraded |

---

## Error Handling

Global error handling via `@ControllerAdvice`:

```java
// In errors/ package
@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(EntityNotFoundException ex) {
        return ResponseEntity.status(404).body(new ErrorResponse(ex.getMessage()));
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ErrorResponse> handleForbidden(AccessDeniedException ex) {
        return ResponseEntity.status(403).body(new ErrorResponse("Access denied"));
    }
}
```

---

## How-To: Add a New Endpoint

1. **Create controller** (or extend existing one):

```java
// src/main/java/com/github/lamarios/newsku/controllers/MyController.java
@RestController
@RequestMapping("/api/my-resource")
public class MyController {
    private final MyService myService;

    @GetMapping
    public List<MyDto> getAll(Authentication auth) {
        return myService.getAll(auth.getName());
    }
}
```

2. **Create service** in `services/`:

```java
@Service
@Transactional
public class MyService {
    // Logic + repository calls
}
```

3. **Entity + repository** in `persistence/` (if new table)

4. **Flyway migration** in `src/main/resources/db/migration/`

---

## Related Documents

- [docs/architektur.md](architektur.md) — Request flow, auth flow
- [docs/datenbank.md](datenbank.md) — JPA entities, Flyway schema
- [docs/haeufige-aufgaben.md](haeufige-aufgaben.md) — End-to-end feature guide
