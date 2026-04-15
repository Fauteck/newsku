# Code-Konventionen

← [Zurueck zum Index](../CLAUDE.md)

---

## Java (Backend)

### Allgemein

- **Java 25** mit modernen Sprachfeatures (Records, Pattern Matching wo sinnvoll)
- **Spring-Konventionen:** Constructor Injection bevorzugen (kein `@Autowired` auf Felder)
- **Lombok:** Vermeiden — explizite Getter/Setter oder Records verwenden
- **Transaktionen:** `@Transactional` auf Service-Methoden, nicht auf Controller
- **Validation:** Jakarta Validation Annotationen (`@NotBlank`, `@Email`, `@Size`, etc.)

### Naming

| Kontext | Konvention | Beispiel |
|---------|-----------|---------|
| Klassen | `PascalCase` | `FeedItemService`, `UserController` |
| Methoden | `camelCase` | `getFeedsForUser()`, `markAsRead()` |
| Variablen | `camelCase` | `feedItems`, `userId` |
| Konstanten | `UPPER_SNAKE_CASE` | `MAX_FEEDS_PER_USER` |
| Pakete | `lowercase` | `com.github.lamarios.newsku.services` |
| DB-Spalten (JPA `@Column`) | `snake_case` | `feed_url`, `created_at`, `importance_score` |
| REST-Pfade | `kebab-case` | `/api/feed-items`, `/api/feed-categories` |
| DTO-Klassen | `PascalCaseRequest/Response` | `CreateFeedRequest`, `FeedItemResponse` |

### Paketstruktur

```
controllers/   → REST Controller (HTTP-Layer, kein Business-Code)
services/      → Geschaeftslogik + Orchestrierung
persistence/
  entities/    → JPA Entities (direkt auf DB-Tabellen gemappt)
  repositories/→ Spring Data JPA Interfaces
security/      → JWT, OIDC, Spring Security Config
errors/        → Custom Exceptions + GlobalExceptionHandler
utils/         → Reine Hilfsfunktionen (stateless)
```

### Service-Muster

```java
// Bevorzugt: Constructor Injection
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

### Fehlerbehandlung

```java
// Custom Exception
public class FeedNotFoundException extends RuntimeException {
    public FeedNotFoundException(String id) {
        super("Feed nicht gefunden: " + id);
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
        log.info("Feed wird aktualisiert: feedId={}", feedId);
        try {
            // ...
        } catch (Exception e) {
            log.error("Feed-Aktualisierung fehlgeschlagen: feedId={}", feedId, e);
        }
    }
}
```

---

## Dart / Flutter (Frontend)

### Allgemein

- **Dart Analyzer:** `analysis_options.yaml` konfiguriert, keine Warnungen ignorieren
- **const-First:** `const` bei Widgets nutzen wo moeglich (Performance)
- **Immutability:** Modell-Klassen unveraenderlich (finale Felder)
- **Null Safety:** Dart Null Safety konsequent nutzen, `!` nur wenn sicher

### Naming

| Kontext | Konvention | Beispiel |
|---------|-----------|---------|
| Klassen | `PascalCase` | `FeedItem`, `AuthBloc`, `FeedService` |
| Methoden / Funktionen | `camelCase` | `getFeeds()`, `markAsRead()` |
| Variablen | `camelCase` | `feedItems`, `isLoading` |
| Konstanten | `camelCase` (Dart-Konvention) | `maxFeedsPerPage` |
| Dateien | `snake_case` | `feed_item.dart`, `feed_service.dart` |
| BLoC-Events | `PascalCase + Event-Suffix` | `LoadFeedsEvent`, `MarkAsReadEvent` |
| BLoC-States | `PascalCase + State-Suffix` | `FeedsLoadedState`, `FeedsErrorState` |

### Datei-Struktur pro Modul

```
lib/mein_modul/
├── mein_modul_bloc.dart         # BLoC (Events + States + Logik)
├── mein_modul_service.dart      # HTTP-Service
├── mein_modul_view.dart         # Haupt-Widget (Screen)
└── models/
    └── mein_model.dart          # Datenmodell (fromJson/toJson)
```

### Modell-Pattern

```dart
class FeedItem {
  final String id;
  final String title;
  final String? imageUrl;         // nullable Felder als ?
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

### Widget-Pattern

```dart
// Bevorzugt: StatelessWidget + BlocBuilder
class FeedList extends StatelessWidget {
  const FeedList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) => switch (state) {
        FeedLoading() => const CircularProgressIndicator(),
        FeedLoaded(:final feeds) => _buildList(feeds),
        FeedError(:final message) => Text('Fehler: $message'),
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

## API-Konventionen

### REST-Endpunkte

- **Plural:** `/api/feeds`, `/api/feed-items` (nicht Singular)
- **Verschachtelung:** nur eine Ebene: `/api/feeds/{id}/items`
- **Spezial-Endpunkte:** `/api/search`, `/api/config`

### Response-Format

```json
// Einzelnes Objekt
{ "id": "...", "title": "...", "feedUrl": "..." }

// Liste
[ { "id": "..." }, { "id": "..." } ]

// Paginiert (wenn implementiert)
{ "content": [...], "totalElements": 42, "totalPages": 3 }

// Fehler
{ "message": "Feed nicht gefunden", "status": 404 }
```

---

## Verwandte Dokumente

- [docs/api-patterns.md](api-patterns.md) — Route-Struktur, Controller-Muster
- [docs/frontend-patterns.md](frontend-patterns.md) — Flutter BLoC, Widgets
- [docs/testing.md](testing.md) — Test-Organisation
