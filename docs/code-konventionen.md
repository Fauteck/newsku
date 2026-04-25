# Code Conventions

← [Back to Index](../CLAUDE.md)

---

## Java (Backend)

### General

- **Java 25** with modern language features (records, pattern matching where appropriate)
- **Spring conventions:** Prefer constructor injection (no `@Autowired` on fields)
- **Lombok:** Avoid — use explicit getters/setters or records
- **Transactions:** `@Transactional` on service methods, not on controllers
- **Validation:** Jakarta Validation annotations (`@NotBlank`, `@Email`, `@Size`, etc.)

### Naming

| Context | Convention | Example |
|---------|-----------|---------|
| Classes | `PascalCase` | `FeedItemService`, `UserController` |
| Methods | `camelCase` | `getFeedsForUser()`, `markAsRead()` |
| Variables | `camelCase` | `feedItems`, `userId` |
| Constants | `UPPER_SNAKE_CASE` | `MAX_FEEDS_PER_USER` |
| Packages | `lowercase` | `com.github.lamarios.newsku.services` |
| DB columns (JPA `@Column`) | `snake_case` | `feed_url`, `created_at`, `importance_score` |
| REST paths | `kebab-case` | `/api/feed-items`, `/api/feed-categories` |
| DTO classes | `PascalCaseRequest/Response` | `CreateFeedRequest`, `FeedItemResponse` |

### Package Structure

```
controllers/   → REST controllers (HTTP layer, no business code)
services/      → Business logic + orchestration
persistence/
  entities/    → JPA entities (mapped directly to DB tables)
  repositories/→ Spring Data JPA interfaces
security/      → JWT, OIDC, Spring Security config
errors/        → Custom exceptions + GlobalExceptionHandler
utils/         → Pure helper functions (stateless)
```

### Service Pattern

```java
// Preferred: constructor injection
@Service
@Transactional
public class FeedService {

    private final FeedRepository feedRepository;
    private final OpenaiService openaiService;

    public FeedService(FeedRepository feedRepository, OpenaiService openaiService) {
        this.feedRepository = feedRepository;
        this.openaiService = openaiService;
    }
}
```

### Error Handling

```java
// Custom exception
public class FeedNotFoundException extends RuntimeException {
    public FeedNotFoundException(String id) {
        super("Feed not found: " + id);
    }
}

// GlobalExceptionHandler
@ControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(FeedNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(FeedNotFoundException ex) {
        return ResponseEntity.status(404).body(new ErrorResponse(ex.getMessage()));
    }
}
```

### Logging

```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class FeedService {
    private static final Logger log = LoggerFactory.getLogger(FeedService.class);

    public void refreshFeed(String feedId) {
        log.info("Refreshing feed: feedId={}", feedId);
        try {
            // ...
        } catch (Exception e) {
            log.error("Feed refresh failed: feedId={}", feedId, e);
        }
    }
}
```

---

## Dart / Flutter (Frontend)

### General

- **Dart Analyzer:** `analysis_options.yaml` configured — do not suppress warnings
- **const-first:** Use `const` on widgets where possible (performance)
- **Immutability:** Model classes immutable (final fields)
- **Null safety:** Use Dart null safety consistently; `!` only when certain

### Naming

| Context | Convention | Example |
|---------|-----------|---------|
| Classes | `PascalCase` | `FeedItem`, `AuthBloc`, `FeedService` |
| Methods / Functions | `camelCase` | `getFeeds()`, `markAsRead()` |
| Variables | `camelCase` | `feedItems`, `isLoading` |
| Constants | `camelCase` (Dart convention) | `maxFeedsPerPage` |
| Files | `snake_case` | `feed_item.dart`, `feed_service.dart` |
| BLoC events | `PascalCase + Event suffix` | `LoadFeedsEvent`, `MarkAsReadEvent` |
| BLoC states | `PascalCase + State suffix` | `FeedsLoadedState`, `FeedsErrorState` |

### File Structure per Module

```
lib/my_module/
├── my_module_bloc.dart         # BLoC (events + states + logic)
├── my_module_service.dart      # HTTP service
├── my_module_view.dart         # Main widget (screen)
└── models/
    └── my_model.dart           # Data model (fromJson/toJson)
```

### Model Pattern

```dart
class FeedItem {
  final String id;
  final String title;
  final String? imageUrl;         // nullable fields as ?
  final double? importanceScore;
  final bool read;

  const FeedItem({
    required this.id,
    required this.title,
    this.imageUrl,
    this.importanceScore,
    required this.read,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      id: json['id'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String?,
      importanceScore: (json['importanceScore'] as num?)?.toDouble(),
      read: json['read'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'imageUrl': imageUrl,
    'importanceScore': importanceScore,
    'read': read,
  };
}
```

### Widget Pattern

```dart
// Preferred: StatelessWidget + BlocBuilder
class FeedList extends StatelessWidget {
  const FeedList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) => switch (state) {
        FeedLoading() => const CircularProgressIndicator(),
        FeedLoaded(:final feeds) => _buildList(feeds),
        FeedError(:final message) => Text('Error: $message'),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildList(List<Feed> feeds) => ListView.builder(
    itemCount: feeds.length,
    itemBuilder: (context, index) => FeedTile(feed: feeds[index]),
  );
}
```

---

## API Conventions

### REST Endpoints

- **Plural:** `/api/feeds`, `/api/feed-items` (not singular)
- **Nesting:** one level only: `/api/feeds/{id}/items`
- **Special endpoints:** `/api/search`, `/api/config`

### Response Format

```json
// Single object
{ "id": "...", "title": "...", "feedUrl": "..." }

// List
[ { "id": "..." }, { "id": "..." } ]

// Paginated (if implemented)
{ "content": [...], "totalElements": 42, "totalPages": 3 }

// Error
{ "message": "Feed not found", "status": 404 }
```

---

## Related Documents

- [docs/api-patterns.md](api-patterns.md) — Route structure, controller patterns
- [docs/frontend-patterns.md](frontend-patterns.md) — Flutter BLoC, widgets
- [docs/testing.md](testing.md) — Test organisation
