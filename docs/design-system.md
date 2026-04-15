# Design System

← [Zurueck zum Index](../CLAUDE.md)

---

## Uebersicht

Newsku nutzt **Flutter Material Design 3** als UI-Framework fuer alle Plattformen (Web, Android).
Es gibt kein separates CSS-basiertes Design System — alle UI-Komponenten werden in Dart/Flutter implementiert.

---

## Material Design 3

Das Flutter-Frontend basiert auf Material Design 3:

- **Package:** `material` (Flutter Core)
- **Dynamic Color:** `dynamic_color` Package — nutzt die Systemfarbe des Geraets
- **Dark/Light Mode:** Automatisch via `ThemeMode.system`
- **Dokumentation:** https://m3.material.io

### Theme-Konfiguration

```dart
// lib/main.dart (vereinfacht)
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

### Dynamic Color (Systemfarbe)

```dart
// Mit dynamic_color Package
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

## Typografie

Flutter M3 Typografiesystem wird direkt ueber `Theme.of(context).textTheme` genutzt:

| Style | Verwendung |
|-------|-----------|
| `displayLarge` | Grosse Ueberschriften (selten) |
| `headlineLarge` | Seiten-Titel |
| `headlineMedium` | Abschnitts-Titel |
| `titleLarge` | Karten-Titel, Feed-Namen |
| `titleMedium` | Sub-Titel |
| `bodyLarge` | Haupttext, Beitraege |
| `bodyMedium` | Standard-Text |
| `bodySmall` | Metadaten, Timestamps |
| `labelLarge` | Buttons, Actions |
| `labelSmall` | Tags, Badges |

```dart
// Verwendung
Text(
  feed.title,
  style: Theme.of(context).textTheme.titleLarge,
)
```

---

## Farben

Alle Farben aus dem `ColorScheme` verwenden — **keine hardcodierten Hex-Farben**:

| Farbe | Verwendung |
|-------|-----------|
| `colorScheme.primary` | Hauptaktionsfarbe, Buttons |
| `colorScheme.secondary` | Sekundaere Aktionen |
| `colorScheme.surface` | Karten-Hintergrund |
| `colorScheme.surfaceVariant` | Leicht abgehobene Flaechen |
| `colorScheme.background` | Seiten-Hintergrund |
| `colorScheme.error` | Fehlermeldungen |
| `colorScheme.onPrimary` | Text auf Primary-Farbe |
| `colorScheme.onSurface` | Text auf Surface |

```dart
Container(
  color: Theme.of(context).colorScheme.surface,
  child: Text(
    'Feed-Eintrag',
    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
  ),
)
```

---

## Kern-Widgets

### Wichtigkeitsanzeige (LLM Score)

Feed-Items erhalten einen `importanceScore` (0.0–1.0) vom LLM.
Dieser wird visuell dargestellt (z. B. farbige Markierung, Reihenfolge).

```dart
// Farbe nach Score
Color getImportanceColor(double score) {
  if (score >= 0.8) return Colors.red.shade400;     // Sehr wichtig
  if (score >= 0.5) return Colors.orange.shade400;  // Wichtig
  return Colors.grey.shade400;                       // Normal
}
```

### Feed-Karte

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

Breakpoints (angelehnt an Material Design):

| Breite | Layout |
|--------|--------|
| < 600 dp | Mobile (einspaltiger Feed) |
| 600–1200 dp | Tablet (optionale Sidebar) |
| > 1200 dp | Desktop (permanente Sidebar) |

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

Flutter Material Icons werden direkt genutzt:

```dart
Icon(Icons.rss_feed)           // Feed-Symbol
Icon(Icons.search)             // Suche
Icon(Icons.settings)           // Einstellungen
Icon(Icons.mark_email_read)    // Als gelesen markieren
Icon(Icons.refresh)            // Feed aktualisieren
Icon(Icons.category)           // Kategorie
Icon(Icons.bar_chart)          // Statistiken
Icon(Icons.open_in_new)        // Externen Link oeffnen
```

---

## PWA (Web)

Der Flutter Web Build ist als PWA konfiguriert:

- **Manifest:** `src/main/app/web/manifest.json`
- **Icons:** `src/main/app/web/icons/` (192x192, 512x512)
- **Service Worker:** Flutter generiert automatisch einen Service Worker

---

## Verwandte Dokumente

- [docs/frontend-patterns.md](frontend-patterns.md) — BLoC, Routing, Services
- [docs/code-konventionen.md](code-konventionen.md) — Dart/Flutter Code-Stil
