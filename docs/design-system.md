# Design System (Flutter Reference)

← [Back to Index](../CLAUDE.md)

> **Note:** This file documents Flutter/M3 implementation patterns.
> The canonical design token specification (colours, typography, spacing, motion)
> lives in [DESIGN.md](../DESIGN.md).

---

## Overview

Newsku uses **Flutter Material Design 3** as the UI framework for all platforms
(Web, Android). There is no separate CSS-based design system — all UI components
are implemented in Dart/Flutter.

---

## Material Design 3

The Flutter frontend is based on Material Design 3:

- **Package:** `material` (Flutter Core)
- **Dynamic Colour:** `dynamic_color` package — uses the device's system colour
- **Dark/Light mode:** Automatic via `ThemeMode.system`
- **Documentation:** https://m3.material.io

### Theme Configuration

```dart
// lib/main.dart (simplified)
MaterialApp.router(
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
  ),
  darkTheme: ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
  ),
  themeMode: ThemeMode.system,
  routerConfig: _appRouter.config(),
)
```

### Dynamic Colour (System Colour)

```dart
// With dynamic_color package
DynamicColorBuilder(
  builder: (lightDynamic, darkDynamic) {
    final lightScheme = lightDynamic ?? ColorScheme.fromSeed(seedColor: Colors.blue);
    final darkScheme = darkDynamic ?? ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    );
    return MaterialApp.router(
      theme: ThemeData(useMaterial3: true, colorScheme: lightScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkScheme),
    );
  },
)
```

---

## Typography

Flutter M3 typography is used directly via `Theme.of(context).textTheme`:

| Style | Usage |
|-------|-------|
| `displayLarge` | Large headlines (rare) |
| `headlineLarge` | Page titles |
| `headlineMedium` | Section titles |
| `titleLarge` | Card titles, feed names |
| `titleMedium` | Sub-titles |
| `bodyLarge` | Main text, articles |
| `bodyMedium` | Standard text |
| `bodySmall` | Metadata, timestamps |
| `labelLarge` | Buttons, actions |
| `labelSmall` | Tags, badges |

```dart
// Usage
Text(
  feed.title,
  style: Theme.of(context).textTheme.titleLarge,
)
```

---

## Colours

Use all colours from `ColorScheme` — **no hardcoded hex values**:

| Colour | Usage |
|--------|-------|
| `colorScheme.primary` | Main action colour, buttons |
| `colorScheme.secondary` | Secondary actions |
| `colorScheme.surface` | Card background |
| `colorScheme.surfaceVariant` | Slightly elevated surfaces |
| `colorScheme.background` | Page background |
| `colorScheme.error` | Error messages |
| `colorScheme.onPrimary` | Text on primary colour |
| `colorScheme.onSurface` | Text on surface |

```dart
Container(
  color: Theme.of(context).colorScheme.surface,
  child: Text(
    'Feed entry',
    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
  ),
)
```

---

## Core Widgets

### Importance Indicator (LLM Score)

Feed items receive an `importanceScore` (0.0–1.0) from the LLM.
This is visualised (e.g. colour marker, ordering).

```dart
// Colour by score
Color getImportanceColor(double score) {
  if (score >= 0.8) return const Color(0xFFEF5350); // High priority
  if (score >= 0.5) return const Color(0xFFFFA726); // Medium priority
  return const Color(0xFFBDBDBD);                   // Normal
}
```

### Feed Card

```dart
Card(
  elevation: 0,
  color: Theme.of(context).colorScheme.surfaceVariant,
  child: ListTile(
    leading: CachedNetworkImage(imageUrl: item.imageUrl),
    title: Text(item.title, style: Theme.of(context).textTheme.titleMedium),
    subtitle: Text(item.feedName, style: Theme.of(context).textTheme.bodySmall),
    trailing: Icon(
      Icons.circle,
      size: 10,
      color: getImportanceColor(item.importanceScore ?? 0),
    ),
  ),
)
```

---

## Responsive Layout

Breakpoints (aligned with Material Design):

| Width | Layout |
|-------|--------|
| < 500 dp | Mobile (single-column feed) |
| 500–800 dp | Tablet (optional sidebar) |
| > 800 dp | Desktop (permanent sidebar) |

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 1200) {
      return DesktopLayout(child: content);
    } else if (constraints.maxWidth > 600) {
      return TabletLayout(child: content);
    }
    return MobileLayout(child: content);
  },
)
```

---

## Icons

Flutter Material Icons are used directly:

```dart
Icon(Icons.rss_feed)           // Feed symbol
Icon(Icons.search)             // Search
Icon(Icons.settings)           // Settings
Icon(Icons.mark_email_read)    // Mark as read
Icon(Icons.refresh)            // Refresh feed
Icon(Icons.category)           // Category
Icon(Icons.bar_chart)          // Statistics
Icon(Icons.open_in_new)        // Open external link
```

---

## PWA (Web)

The Flutter web build is configured as a PWA:

- **Manifest:** `src/main/app/web/manifest.json`
- **Icons:** `src/main/app/web/icons/` (192x192, 512x512)
- **Service Worker:** Flutter automatically generates a service worker

---

## Related Documents

- [DESIGN.md](../DESIGN.md) — Canonical token specification (colours, spacing, motion)
- [docs/frontend-patterns.md](frontend-patterns.md) — BLoC, routing, services
- [docs/code-konventionen.md](code-konventionen.md) — Dart/Flutter code style
