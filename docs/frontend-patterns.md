# Frontend Patterns

← [Back to Index](../CLAUDE.md)

---

## Overview

The frontend is a Flutter app that runs as both a Progressive Web App (PWA) and
a native Android app. The Flutter web build is served statically by the Spring
Boot backend (`StaticContentController`).

```
main.dart (Flutter entry point)
  │
  ├─ router.dart (auto_route routing)
  │
  ├─ identity/ (login state, auth BLoC)
  │
  └─ Screens / Views
       │
       ├─ feed/ (feed overview, item detail)
       ├─ settings/ (feeds, layout, user account)
       ├─ stats/ (click statistics)
       ├─ layouts/ (layout customisation)
       └─ home/ (home screen)
```

---

## Routing

Routing is defined declaratively via `auto_route` in `lib/router.dart`.
Generated routes are in `lib/router.gr.dart` (do not edit manually).

| Route | Description |
|-------|-------------|
| `/login` | Login form |
| `/` | Home screen (feed overview) |
| `/feed/:id` | Feed detail / articles of a feed |
| `/item/:id` | Feed article detail |
| `/search` | Search results |
| `/settings` | Settings (feeds, layout, account) |
| `/settings/feeds` | Feed management |
| `/settings/layout` | Layout customisation |
| `/stats` | Click statistics |

All routes except `/login` are protected by an auth guard.

---

## State Management (BLoC)

The project uses `flutter_bloc` for state management:

```
Event → BLoC → State → UI (rebuild)
```

### Key BLoCs

| BLoC | Location | Purpose |
|------|----------|---------|
| `AuthBloc` / `IdentityBloc` | `lib/identity/` | Login/logout state, token management |
| `FeedBloc` | `lib/feed/` | Feed list, currently selected feed |
| `FeedItemBloc` | `lib/feed/` | Load feed articles, read status |
| `SettingsBloc` | `lib/settings/` | Read/write settings |
| `LayoutBloc` | `lib/layouts/` | Layout blocks |

### BLoC Pattern Example

```dart
// Define event
abstract class FeedEvent {}
class LoadFeeds extends FeedEvent {}
class RefreshFeed extends FeedEvent {
  final String feedId;
  RefreshFeed(this.feedId);
}

// Define state
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

// Implement BLoC
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

### Using BLoC in UI

```dart
// Widget with BlocBuilder
BlocBuilder<FeedBloc, FeedState>(
  builder: (context, state) {
    if (state is FeedLoading) return CircularProgressIndicator();
    if (state is FeedError) return Text('Error: ${state.message}');
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

## HTTP Services

Base HTTP functionality is defined in `lib/base_service.dart`.
Each module has its own service:

| Service | Location | Purpose |
|---------|----------|---------|
| `FeedService` | `lib/feed/` | Feeds + feed items via REST API |
| `UserService` | `lib/user/` | Login, OIDC, profile |
| `SettingsService` | `lib/settings/` | Settings |
| `LayoutService` | `lib/layouts/` | Layout blocks |
| `StatsService` | `lib/stats/` | Click statistics |

### Service Pattern Example

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

## Authentication

- **JWT:** Token is stored in local storage (`shared_preferences`) after login
- **OIDC:** Optional via `oidc` package (when server has OIDC configured)
- **Token handling:** `BaseService` automatically adds `Authorization: Bearer <token>`
- **Redirect:** On 401 → logout and redirect to `/login`

---

## Styling (Material Design 3)

- **Framework:** Flutter Material Design 3
- **Dynamic Colour:** `dynamic_color` package (use system accent colour)
- **Dark/Light mode:** System setting is respected
- **Responsive:** Adapts to different screen sizes via MediaQuery + LayoutBuilder

See [DESIGN.md](../DESIGN.md) for the complete token specification.

```dart
// Example: responsive layout
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

## Platforms

| Platform | Build Command | Notes |
|----------|--------------|-------|
| Web (PWA) | `flutter build web` | Embedded in `src/main/resources/static/` |
| Android | `flutter build apk` / `flutter build appbundle` | Release in GitHub Releases |
| iOS | `flutter build ios` | Not officially supported |
| Linux/macOS | `flutter build linux/macos` | Community support |

The web build is served by the Spring Boot backend (`StaticContentController` → all
non-API routes).

---

## How-To: Add New Module / Screen

1. **Create directory** in `lib/`:

```
lib/my-module/
├── my_module_service.dart    # HTTP service
├── my_module_bloc.dart       # BLoC (events, states, logic)
├── my_module_view.dart       # Main UI widget
└── models/
    └── my_model.dart         # Data model + fromJson/toJson
```

2. **Register route** in `lib/router.dart`:

```dart
AutoRoute(page: MyModulePage, path: '/my-module'),
```

3. **Provide BLoC** in the widget tree (e.g. in `main.dart` or directly in the screen):

```dart
BlocProvider<MyModulBloc>(
  create: (context) => MyModulBloc(MyModulService()),
  child: MyModulView(),
)
```

4. **Regenerate routes** (once after changing `router.dart`):

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Related Documents

- [docs/api-patterns.md](api-patterns.md) — Backend endpoints
- [docs/code-konventionen.md](code-konventionen.md) — Dart/Flutter code style
- [docs/entwicklung.md](entwicklung.md) — Flutter setup, dev server
- [DESIGN.md](../DESIGN.md) — Design tokens, colours, typography
