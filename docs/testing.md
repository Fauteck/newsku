# Testing

← [Zurueck zum Index](../CLAUDE.md)

---

## Uebersicht

| Schicht | Framework | Ort | Befehl |
|---------|-----------|-----|--------|
| Backend (Unit) | JUnit 5 + Mockito | `src/test/java/` | `mvn test` |
| Backend (Integration) | Spring Boot Test + TestContainers | `src/test/java/` | `mvn verify` |
| Frontend | Flutter Test | `src/main/app/test/` | `flutter test` |

---

## Backend-Tests (Java)

### Voraussetzungen

TestContainers startet automatisch eine echte PostgreSQL-Instanz fuer Integrationstests.
Docker muss auf dem Entwicklungsrechner laufen.

### Test-Befehle

```bash
# Alle Tests (Unit + Integration)
mvn test

# Nur Tests, kein Package
mvn test -pl .

# Tests ueberspringen (fuer schnellen Build)
mvn clean package -DskipTests

# Einzelne Test-Klasse ausfuehren
mvn test -Dtest=FeedServiceTest

# Einzelne Test-Methode
mvn test -Dtest=FeedServiceTest#shouldReturnFeedsForUser
```

### Unit-Test-Pattern

```java
// src/test/java/com/github/lamarios/newsku/services/FeedServiceTest.java

@ExtendWith(MockitoExtension.class)
class FeedServiceTest {

    @Mock
    private FeedRepository feedRepository;

    @Mock
    private OpenaiService openaiService;

    @InjectMocks
    private FeedService feedService;

    @Test
    void shouldReturnFeedsForUser() {
        // Arrange
        String userId = "user-123";
        Feed feed = new Feed();
        feed.setId("feed-1");
        feed.setUserId(userId);

        when(feedRepository.findByUserId(userId)).thenReturn(List.of(feed));

        // Act
        List<Feed> result = feedService.getFeedsForUser(userId);

        // Assert
        assertThat(result).hasSize(1);
        assertThat(result.get(0).getId()).isEqualTo("feed-1");
        verify(feedRepository).findByUserId(userId);
    }

    @Test
    void shouldThrowWhenFeedNotFound() {
        // Arrange
        when(feedRepository.findByIdAndUserId(anyString(), anyString()))
            .thenReturn(Optional.empty());

        // Act & Assert
        assertThatThrownBy(() -> feedService.getFeed("user-1", "unknown-id"))
            .isInstanceOf(FeedNotFoundException.class);
    }
}
```

### Integrations-Test-Pattern (TestContainers)

```java
// src/test/java/com/github/lamarios/newsku/integration/FeedControllerIT.java

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
class FeedControllerIT {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:18-alpine")
        .withDatabaseName("newsku_test")
        .withUsername("test")
        .withPassword("test");

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
    }

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    void shouldReturnEmptyFeedsForNewUser() {
        // JWT-Token fuer Testbenutzer generieren (oder Mock-Auth)
        ResponseEntity<List> response = restTemplate.exchange(
            "/api/feeds",
            HttpMethod.GET,
            new HttpEntity<>(authHeaders()),
            List.class
        );

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isEmpty();
    }
}
```

### Controller-Test (MockMvc)

```java
@WebMvcTest(FeedController.class)
class FeedControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private FeedService feedService;

    @Test
    @WithMockUser(username = "user-123")
    void getFeeds_shouldReturn200() throws Exception {
        when(feedService.getFeedsForUser("user-123"))
            .thenReturn(Collections.emptyList());

        mockMvc.perform(get("/api/feeds"))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON))
            .andExpect(jsonPath("$").isArray());
    }
}
```

---

## Frontend-Tests (Flutter)

### Test-Befehle

```bash
cd src/main/app

# Alle Tests ausfuehren
flutter test

# Einzelne Test-Datei
flutter test test/feed_service_test.dart

# Mit Coverage
flutter test --coverage
```

### Unit-Test-Pattern (Dart)

```dart
// src/main/app/test/feed_item_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:newsku/feed/models/feed_item.dart';

void main() {
  group('FeedItem', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'item-1',
        'title': 'Test Artikel',
        'imageUrl': null,
        'importanceScore': 0.85,
        'read': false,
      };

      final item = FeedItem.fromJson(json);

      expect(item.id, equals('item-1'));
      expect(item.title, equals('Test Artikel'));
      expect(item.imageUrl, isNull);
      expect(item.importanceScore, closeTo(0.85, 0.001));
      expect(item.read, isFalse);
    });

    test('toJson serializes correctly', () {
      final item = FeedItem(
        id: 'item-1',
        title: 'Test',
        read: true,
      );

      final json = item.toJson();

      expect(json['id'], equals('item-1'));
      expect(json['read'], isTrue);
    });
  });
}
```

### BLoC-Test-Pattern

```dart
// src/main/app/test/feed_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class MockFeedService extends Mock implements FeedService {}

void main() {
  late MockFeedService mockFeedService;

  setUp(() {
    mockFeedService = MockFeedService();
  });

  group('FeedBloc', () {
    blocTest<FeedBloc, FeedState>(
      'emits [FeedLoading, FeedLoaded] when LoadFeeds succeeds',
      build: () {
        when(() => mockFeedService.getFeeds())
            .thenAnswer((_) async => [Feed(id: '1', title: 'Feed 1')]);
        return FeedBloc(mockFeedService);
      },
      act: (bloc) => bloc.add(LoadFeeds()),
      expect: () => [
        isA<FeedLoading>(),
        isA<FeedLoaded>(),
      ],
    );
  });
}
```

### Widget-Test-Pattern

```dart
// src/main/app/test/widgets/feed_tile_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FeedTile zeigt Titel an', (WidgetTester tester) async {
    final feed = Feed(id: '1', title: 'Mein Test-Feed');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeedTile(feed: feed),
        ),
      ),
    );

    expect(find.text('Mein Test-Feed'), findsOneWidget);
  });
}
```

---

## How-To: Neuen Test schreiben

### Backend (Service-Test)

1. Datei erstellen: `src/test/java/com/github/lamarios/newsku/services/MeinServiceTest.java`
2. `@ExtendWith(MockitoExtension.class)` verwenden
3. Abhaengigkeiten mit `@Mock` mocken
4. Service mit `@InjectMocks` instanziieren

### Backend (Integrations-Test)

1. Datei erstellen: `src/test/java/com/github/lamarios/newsku/integration/MeinIT.java`
2. `@SpringBootTest` + `@Testcontainers` nutzen
3. PostgreSQL Container via `@Container` starten
4. Properties via `@DynamicPropertySource` einfuegen

### Flutter (Unit-Test)

1. Datei erstellen: `src/main/app/test/mein_test.dart`
2. `flutter_test` importieren
3. `group()` + `test()` / `testWidgets()` nutzen

---

## Verwandte Dokumente

- [docs/entwicklung.md](entwicklung.md) — Dev-Setup, Build-Befehle
- [docs/api-patterns.md](api-patterns.md) — Was getestet werden soll
