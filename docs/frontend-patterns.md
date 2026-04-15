# Frontend-Patterns

← [Zurueck zum Index](../CLAUDE.md)

---

## Uebersicht

Das Frontend ist eine Flutter-App, die sowohl als Progressive Web App (PWA) als auch als native Android-App laeuft.
Der Flutter Web Build wird vom Spring Boot Backend statisch ausgeliefert (`StaticContentController`).

```
main.dart (Flutter Einstiegspunkt)
  │
  ├─ router.dart (auto_route Routing)
  │
  ├─ identity/ (Login-State, Auth-BLoC)
  │
  └─ Screens / Views
       │
       ├─ feed/ (Feed-Uebersicht, Item-Detail)
       ├─ settings/ (Feeds, Layout, Benutzerkonto)
       ├─ stats/ (Klick-Statistiken)
       ├─ layouts/ (Layout-Anpassung)
       └─ home/ (Startseite)
```

---

## Routing

Routing wird via `auto_route` deklarativ definiert in `lib/router.dart`.
Die generierten Routen liegen in `lib/router.gr.dart` (nicht manuell bearbeiten).

| Route | Beschreibung |
|-------|-------------|
| `/login` | Login-Formular |
| `/` | Startseite (Feed-Uebersicht) |
| `/feed/:id` | Feed-Detail / Beitraege eines Feeds |
| `/item/:id` | Feed-Beitrag Detail |
| `/search` | Suchergebnisse |
| `/settings` | Einstellungen (Feeds, Layout, Konto) |
| `/settings/feeds` | Feed-Verwaltung |
| `/settings/layout` | Layout-Anpassung |
| `/stats` | Klick-Statistiken |

Alle Routen ausser `/login` sind durch Auth-Guard geschuetzt.

---

## State Management (BLoC)

Das Projekt nutzt `flutter_bloc` fuer State Management:

```
Event → BLoC → State → UI (rebuild)
```

### Wichtige BLoCs

| BLoC | Ort | Zweck |
|------|-----|-------|
| `AuthBloc` / `IdentityBloc` | `lib/identity/` | Login/Logout-State, Token-Verwaltung |
| `FeedBloc` | `lib/feed/` | Feed-Liste, aktuell selektierter Feed |
| `FeedItemBloc` | `lib/feed/` | Feed-Beitraege laden, gelesen-Status |
| `SettingsBloc` | `lib/settings/` | Einstellungen lesen/schreiben |
| `LayoutBloc` | `lib/layouts/` | Layout-Bloecke |

### BLoC-Pattern Beispiel

```dart
// Event definieren
abstract class FeedEvent {}
class LoadFeeds extends FeedEvent {}
class RefreshFeed extends FeedEvent {
  final String feedId;
  RefreshFeed(this.feedId);
}

// State definieren
abstract class FeedState {}
class FeedLoading extends FeedState {}
class FeedLoaded extends FeedState {
  final List<Feed> feeds;
  FeedLoaded(this.feeds);
}
class FeedError extends FeedState {
  final String message;
  FeedError(this.message);
}

// BLoC implementieren
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final FeedService feedService;

  FeedBloc(this.feedService) : super(FeedLoading()) {
    on<LoadFeeds>(_onLoadFeeds);
  }

  Future<void> _onLoadFeeds(LoadFeeds event, Emitter<FeedState> emit) async {
    emit(FeedLoading());
    try {
      final feeds = await feedService.getFeeds();
      emit(FeedLoaded(feeds));
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }
}
```

### BLoC in der UI verwenden

```dart
// Widget mit BlocBuilder
BlocBuilder<FeedBloc, FeedState>(
  builder: (context, state) {
    if (state is FeedLoading) return CircularProgressIndicator();
    if (state is FeedError) return Text('Fehler: ${state.message}');
    if (state is FeedLoaded) {
      return ListView(
        children: state.feeds.map((f) => FeedTile(feed: f)).toList(),
      );
    }
    return SizedBox.shrink();
  },
)
```

---

## HTTP-Services

Basis-HTTP-Funktionalitaet ist in `lib/base_service.dart` definiert.
Jedes Modul hat seinen eigenen Service:

| Service | Ort | Zweck |
|---------|-----|-------|
| `FeedService` | `lib/feed/` | Feeds + Feed-Items via REST API |
| `UserService` | `lib/user/` | Login, OIDC, Profil |
| `SettingsService` | `lib/settings/` | Einstellungen |
| `LayoutService` | `lib/layouts/` | Layout-Bloecke |
| `StatsService` | `lib/stats/` | Klick-Statistiken |

### Service-Pattern Beispiel

```dart
// lib/feed/services/feed_service.dart
class FeedService extends BaseService {

  Future<List<Feed>> getFeeds() async {
    final response = await get('/api/feeds');
    return (response as List)
        .map((json) => Feed.fromJson(json))
        .toList();
  }

  Future<Feed> createFeed(CreateFeedRequest request) async {
    final response = await post('/api/feeds', body: request.toJson());
    return Feed.fromJson(response);
  }
}
```

---

## Authentifizierung

- **JWT:** Token wird nach Login im lokalen Speicher (`shared_preferences`) gesichert
- **OIDC:** Optional via `oidc` Package (wenn Server OIDC konfiguriert hat)
- **Token-Handling:** `BaseService` fuegt `Authorization: Bearer <token>` automatisch hinzu
- **Redirect:** Bei 401 → Logout und Weiterleitung zu `/login`

---

## Styling (Material Design 3)

- **Framework:** Flutter Material Design 3
- **Dynamic Color:** `dynamic_color` Package (System-Akzentfarbe nutzen)
- **Dark/Light Mode:** Systemeinstellung wird respektiert
- **Responsive:** Anpassung an verschiedene Bildschirmgroessen via MediaQuery + LayoutBuilder

```dart
// Beispiel: Responsive Layout
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return DesktopLayout();
    }
    return MobileLayout();
  },
)
```

---

## Plattformen

| Plattform | Build-Befehl | Besonderheiten |
|-----------|-------------|----------------|
| Web (PWA) | `flutter build web` | Wird in `src/main/resources/static/` eingebettet |
| Android | `flutter build apk` / `flutter build appbundle` | Release im GitHub Releases |
| iOS | `flutter build ios` | Nicht offiziell unterstuetzt |
| Linux/macOS | `flutter build linux/macos` | Community-Support |

Der Web Build wird vom Spring Boot Backend ausgeliefert (`StaticContentController` → alle nicht-API Routen).

---

## How-To: Neues Modul / neue Seite hinzufuegen

1. **Verzeichnis anlegen** in `lib/`:

```
lib/mein-modul/
├── mein_modul_service.dart    # HTTP-Service
├── mein_modul_bloc.dart       # BLoC (Events, States, Logik)
├── mein_modul_view.dart       # Haupt-UI-Widget
└── models/
    └── mein_model.dart        # Datenmodell + fromJson/toJson
```

2. **Route registrieren** in `lib/router.dart`:

```dart
AutoRoute(page: MeinModulPage, path: '/mein-modul'),
```

3. **BLoC bereitstellen** im Widget-Tree (z. B. in `main.dart` oder direkt im Screen):

```dart
BlocProvider<MeinModulBloc>(
  create: (context) => MeinModulBloc(MeinModulService()),
  child: MeinModulView(),
)
```

4. **Route generieren** (einmalig nach Aenderung von `router.dart`):

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Verwandte Dokumente

- [docs/api-patterns.md](api-patterns.md) — Backend-Endpunkte
- [docs/code-konventionen.md](code-konventionen.md) — Dart/Flutter Code-Stil
- [docs/entwicklung.md](entwicklung.md) — Flutter Setup, Dev-Server
