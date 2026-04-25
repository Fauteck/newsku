---
name: "Newsku / Feedteck"
version: "1.0.0"
updated: "2026-04-25"
framework: "Flutter / Material Design 3"

tokens:
  color:
    brand:
      seed: "#FF5722"                    # Colors.deepOrange — user-overridable
    surface:
      light:
        base: "#FFFFFF"
        container-high: "#E9EAED"
      dark:
        base: "#111214"                  # Color.fromARGB(255, 17, 18, 20)
        container-high: "#232428"        # Color.fromARGB(255, 35, 36, 40)
        amoled: "#000000"               # user opt-in power-saving mode
    importance:
      high:   "#EF5350"                  # score >= 0.8 — Colors.red.shade400
      medium: "#FFA726"                  # score >= 0.5 — Colors.orange.shade400
      low:    "#BDBDBD"                  # score <  0.5 — Colors.grey.shade400

  typography:
    font-family: "Roboto"
    scale:
      display-large:   { size: "57sp", weight: "400", line-height: "64sp" }
      headline-large:  { size: "32sp", weight: "400", line-height: "40sp" }
      headline-medium: { size: "28sp", weight: "400", line-height: "36sp" }
      title-large:     { size: "22sp", weight: "400", line-height: "28sp" }
      title-medium:    { size: "16sp", weight: "500", line-height: "24sp" }
      body-large:      { size: "16sp", weight: "400", line-height: "24sp" }
      body-medium:     { size: "14sp", weight: "400", line-height: "20sp" }
      body-small:      { size: "12sp", weight: "400", line-height: "16sp" }
      label-large:     { size: "14sp", weight: "500", line-height: "20sp" }
      label-small:     { size: "11sp", weight: "500", line-height: "16sp" }

  spacing:
    xs:  "4dp"
    sm:  "8dp"
    md:  "16dp"
    lg:  "24dp"
    xl:  "32dp"
    xxl: "48dp"

  shape:
    extra-small: "4dp"
    small:       "8dp"
    medium:      "12dp"
    large:       "16dp"
    extra-large: "28dp"
    full:        "9999dp"

  elevation:
    level0: "0dp"
    level1: "1dp"
    level2: "3dp"
    level3: "6dp"
    level4: "8dp"
    level5: "12dp"

  motion:
    duration:
      short1:  "50ms"
      short2:  "100ms"
      short3:  "150ms"
      short4:  "200ms"
      medium1: "250ms"
      medium2: "300ms"
      medium3: "350ms"
      medium4: "400ms"
    easing:
      standard:   "cubic-bezier(0.2, 0, 0, 1.0)"
      decelerate: "cubic-bezier(0, 0, 0, 1)"
      accelerate: "cubic-bezier(0.3, 0, 1, 1)"
      emphasized: "cubic-bezier(0.2, 0, 0, 1.0)"

  breakpoints:
    mobile:      "500dp"
    tablet:      "800dp"
    desktop:     "1280dp"
    big-desktop: "∞"

  iconography:
    default-size: "24dp"
    small-size:   "16dp"
    badge-size:   "10dp"
    style:        "Material Icons"

components:
  feed-card:
    elevation: "{tokens.elevation.level0}"
    shape:     "{tokens.shape.medium}"
    title:     "{tokens.typography.scale.title-medium}"
    subtitle:  "{tokens.typography.scale.body-small}"
    importance-dot:
      high:   "{tokens.color.importance.high}"
      medium: "{tokens.color.importance.medium}"
      low:    "{tokens.color.importance.low}"
      size:   "{tokens.iconography.badge-size}"

  navigation-rail:
    surface:   "{tokens.color.surface.dark.container-high}"
    icon-size: "{tokens.iconography.default-size}"

  input-field:
    border-style: "outline"
    shape:        "{tokens.shape.extra-small}"
---

# Newsku Design System

← [Back to Index](CLAUDE.md)

---

## Philosophy

Newsku uses **Flutter Material Design 3** as its sole UI foundation. There is no
separate CSS layer or custom design system — every visual decision derives from
the M3 token system, with three project-specific additions:

1. **Brand seed colour** (`#FF5722`, deepOrange) — generates the entire adaptive
   colour scheme via `ColorScheme.fromSeed()`.
2. **Fixed surface overrides** — the dark-mode surface and `surfaceContainerHigh`
   values are pinned to specific neutrals to ensure consistent contrast regardless
   of which seed colour the user selects.
3. **Importance colour scale** — a semantic set of three colours that maps LLM
   relevance scores (0.0–1.0) to visual priority indicators.

> Tokens give agents exact values. Prose tells them why those values exist.

---

## Brand & Colour System

### Seed Colour

The brand colour `#FF5722` (Flutter `Colors.deepOrange`) acts exclusively as the
**seed** for `ColorScheme.fromSeed()`. Users can override this value in app
settings; the stored value is an ARGB32 integer in `SharedPreferences`
(`theme-color` key, default `Colors.deepOrange`).

**Dynamic Colour** (Android 12+) is supported: when enabled, the device's system
accent colour replaces the seed entirely. The fixed surface overrides below still
apply in both cases.

```dart
ColorScheme.fromSeed(
  seedColor: appColor,            // user-selected or brand default #FF5722
  brightness: Brightness.dark,
  surface: Color(0xFF111214),     // pinned — does not shift with seed
  surfaceContainerHigh: Color(0xFF232428),
  onSurface: Colors.white,
)
```

### Fixed Surface Overrides

These values are **not** derived from the seed — they are hard-pinned to
guarantee readability across all possible seed colours a user might choose:

| Token | Hex | Context |
|---|---|---|
| `surface.dark.base` | `#111214` | Dark mode page and card background |
| `surface.dark.container-high` | `#232428` | Dark mode elevated surfaces, navigation rail |
| `surface.dark.amoled` | `#000000` | AMOLED / power-saving mode (user opt-in) |
| `surface.light.base` | `#FFFFFF` | Light mode page and card background |
| `surface.light.container-high` | `#E9EAED` | Light mode elevated surfaces |

### Contrast Ratios (WCAG 2.1)

| Combination | Ratio | Level |
|---|---|---|
| `#000000` on `#FFFFFF` (light body text) | 21:1 | AAA ✓ |
| `#FFFFFF` on `#111214` (dark body text) | ~19:1 | AAA ✓ |
| `#FFFFFF` on `#232428` (dark container text) | ~13:1 | AAA ✓ |
| `#000000` on `#E9EAED` (light container text) | ~18:1 | AAA ✓ |

Importance colours (`#EF5350`, `#FFA726`, `#BDBDBD`) are used only as **status
indicator dots** (10dp icons), not as text colours. They are not subject to WCAG
text contrast requirements but must remain distinguishable for colour-blind users.
Consider supplementing with shape or label cues if accessibility becomes a concern.

### Colour Usage Rules

- **Never** hardcode hex values in widget code. Always use
  `Theme.of(context).colorScheme.*`.
- The one sanctioned exception is the importance colour scale (see
  §Importance Visualization), which maps a numeric float to a fixed semantic
  colour set and intentionally bypasses the dynamic colour system.

---

## Typography

Flutter Material 3 typography is consumed directly via
`Theme.of(context).textTheme`. The font family is **Roboto** (bundled by
Flutter on all platforms; Android may substitute the system font).

| Token | Size | Weight | Line-Height | Primary Usage |
|---|---|---|---|---|
| `display-large` | 57sp | 400 | 64sp | Large headers (rare) |
| `headline-large` | 32sp | 400 | 40sp | Page titles |
| `headline-medium` | 28sp | 400 | 36sp | Section headers |
| `title-large` | 22sp | 400 | 28sp | Card titles, feed names |
| `title-medium` | 16sp | 500 | 24sp | Sub-titles |
| `body-large` | 16sp | 400 | 24sp | Main text, article content |
| `body-medium` | 14sp | 400 | 20sp | Standard text |
| `body-small` | 12sp | 400 | 16sp | Metadata, timestamps, feed source |
| `label-large` | 14sp | 500 | 20sp | Buttons, actions |
| `label-small` | 11sp | 500 | 16sp | Tags, badges |

```dart
Text(feed.title, style: Theme.of(context).textTheme.titleLarge)
```

All font sizes use `sp` (scale-independent pixels). Never use `dp` for text —
this breaks system font size accessibility settings.

---

## Spacing System

Spacing follows a **4dp base grid**. Named tokens map to multiples of this unit:

| Token | Value | Typical Use |
|---|---|---|
| `xs` | 4dp | Icon padding, tight gaps between inline elements |
| `sm` | 8dp | Inner card padding, list item gaps |
| `md` | 16dp | Default content padding, horizontal screen margin |
| `lg` | 24dp | Section separation |
| `xl` | 32dp | Screen edge padding on large screens |
| `xxl` | 48dp | Hero/feature section spacing |

**Visual Density** is user-configurable via `LocalPreferences` (`density` key,
default `4.0`). This maps to Flutter's `VisualDensity`, which scales padding
across all M3 components automatically without requiring per-widget overrides.

---

## Shape (Corner Radius)

Shape tokens follow the Material Design 3 shape scale and map directly to
Flutter's `RoundedRectangleBorder`:

| Token | Radius | Use |
|---|---|---|
| `extra-small` | 4dp | Input fields, chips, small surfaces |
| `small` | 8dp | Small buttons |
| `medium` | 12dp | Feed cards, list tiles |
| `large` | 16dp | Bottom sheets (collapsed) |
| `extra-large` | 28dp | Bottom sheets (expanded), dialogs |
| `full` | 9999dp | FABs, avatar circles |

---

## Elevation

M3 encodes elevation as surface tint, not shadow depth. Feed cards use
`level0` (zero tint) to reduce visual noise in dense feed lists.

| Token | Shadow Depth | Typical Use |
|---|---|---|
| `level0` | 0dp | Feed cards — flat, no tint |
| `level1` | 1dp | Menu items |
| `level2` | 3dp | Cards on hover |
| `level3` | 6dp | Navigation drawers |
| `level4` | 8dp | Modal bottom sheets |
| `level5` | 12dp | Dialogs |

---

## Motion & Animation

Newsku inherits the M3 motion system entirely. No custom durations or easing
curves are defined at the project level — all transitions use Flutter's built-in
M3 defaults.

| Token | Duration | Use |
|---|---|---|
| `short1` | 50ms | Micro-interactions (icon state change) |
| `short2` | 100ms | Fade in/out |
| `short3` | 150ms | List item appearance |
| `short4` | 200ms | Standard state transitions |
| `medium1` | 250ms | Page-level transitions |
| `medium2` | 300ms | Bottom sheet open/close |
| `medium3` | 350ms | Dialog entrance |
| `medium4` | 400ms | Full-screen transitions |

| Easing | Curve | Use |
|---|---|---|
| `standard` | `cubic-bezier(0.2, 0, 0, 1.0)` | Default M3 transitions |
| `decelerate` | `cubic-bezier(0, 0, 0, 1)` | Elements entering the screen |
| `accelerate` | `cubic-bezier(0.3, 0, 1, 1)` | Elements leaving the screen |
| `emphasized` | `cubic-bezier(0.2, 0, 0, 1.0)` | Expressive / hero transitions |

---

## Responsive Breakpoints

Breakpoints are implemented as a Dart enum (`BreakPoint`) in
`src/main/app/lib/utils/models/breakpoints.dart`.

| Token | Max Width | Layout |
|---|---|---|
| `mobile` | 500dp | Single-column feed, bottom navigation |
| `tablet` | 800dp | Optional side navigation rail |
| `desktop` | 1280dp | Permanent navigation rail, wider content |
| `big-desktop` | ∞ | Same as desktop, even wider content area |

```dart
final bp = BreakPoint.get(context); // resolves current breakpoint from MediaQuery
```

---

## Iconography

All icons use **Flutter Material Icons**. The icon font ships with Flutter;
no additional dependency is required.

| Token | Value | Use |
|---|---|---|
| `default-size` | 24dp | Navigation icons, action icons |
| `small-size` | 16dp | Inline icons, dense toolbars |
| `badge-size` | 10dp | Importance dot indicator |

Commonly used icons:

| Icon | Identifier | Context |
|---|---|---|
| RSS feed | `Icons.rss_feed` | Feed symbol |
| Search | `Icons.search` | Search bar |
| Settings | `Icons.settings` | Settings screen |
| Mark read | `Icons.mark_email_read` | Mark-as-read action |
| Refresh | `Icons.refresh` | Refresh feed |
| Category | `Icons.category` | Feed categories |
| Statistics | `Icons.bar_chart` | Stats screen |
| Open external | `Icons.open_in_new` | Open article in browser |

Icon-only interactive elements must carry a `Semantics(label: '...')` wrapper
for screen readers (see §Accessibility).

---

## Importance Visualization

The **LLM relevance score** (`importanceScore`, range `0.0`–`1.0`) is the one
place in the codebase where fixed semantic colours are used instead of
`colorScheme.*`. These colours are intentionally static so they remain
recognisable across all seed colours and both light/dark themes.

| Token | Hex | Threshold | Meaning |
|---|---|---|---|
| `importance.high` | `#EF5350` | score ≥ 0.8 | High priority — must-read |
| `importance.medium` | `#FFA726` | score ≥ 0.5 | Medium priority — worth reading |
| `importance.low` | `#BDBDBD` | score < 0.5 | Low priority — optional |

```dart
Color getImportanceColor(double score) {
  if (score >= 0.8) return const Color(0xFFEF5350); // importance.high
  if (score >= 0.5) return const Color(0xFFFFA726); // importance.medium
  return const Color(0xFFBDBDBD);                   // importance.low
}
```

The indicator renders as a `10dp` filled circle (`Icons.circle`, size 10) in
the trailing slot of each feed card `ListTile`. When `importanceScore` is `null`
(not yet ranked), the low colour is used as the default.

---

## Component Tokens

### Feed Card

The primary content unit. A zero-elevation `Card` containing a `ListTile`.

| Property | Token / Value |
|---|---|
| Elevation | `{tokens.elevation.level0}` — flat, no shadow or tint |
| Background | `colorScheme.surfaceVariant` (seed-derived) |
| Shape | `{tokens.shape.medium}` — 12dp corner radius |
| Title style | `{tokens.typography.scale.title-medium}` |
| Subtitle style | `{tokens.typography.scale.body-small}` |
| Importance dot size | `{tokens.iconography.badge-size}` — 10dp |

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

### Navigation Rail

Visible on tablet and desktop breakpoints. Uses `surfaceContainerHigh` as
its background to create visual separation from the feed list.

| Property | Token / Value |
|---|---|
| Background | `{tokens.color.surface.dark.container-high}` in dark mode |
| Icon size | `{tokens.iconography.default-size}` — 24dp |

### Input Fields

All input fields use `OutlineInputBorder`, configured globally in
`ThemeData.inputDecorationTheme` so all fields share the same visual style.

| Property | Token / Value |
|---|---|
| Border style | Outline |
| Corner radius | `{tokens.shape.extra-small}` — 4dp |

---

## Interaction States

Flutter M3 manages hover, pressed, focused, and disabled states via
`MaterialState` / `WidgetState` overlays automatically. No explicit state tokens
are required at the project level.

| State | Visual Effect | M3 Layer |
|---|---|---|
| Hover | Primary colour overlay at 8% opacity | `stateLayer.hovered` |
| Pressed / Ripple | Primary colour ripple at 12% opacity | `stateLayer.pressed` |
| Focused | 3dp primary-coloured focus ring | `stateLayer.focused` |
| Disabled | 38% opacity on content, muted surface | `stateLayer.disabled` |

---

## Accessibility

- **Contrast:** All text/background pairs meet WCAG 2.1 AA; primary surfaces
  achieve AAA (see §Brand & Colour System for calculated ratios).
- **Touch targets:** Minimum 44×44dp on all interactive elements — guaranteed by
  M3 component defaults. Do not reduce `minimumSize` on buttons.
- **Semantics:** Icon-only buttons must carry a semantic label:
  ```dart
  Semantics(label: 'Mark as read', child: IconButton(...))
  ```
- **Screen readers:** M3 widgets ship with built-in accessibility semantics.
  Custom widgets must declare `semanticsLabel` or wrap content in `Semantics`.
- **Text scaling:** All font sizes use `sp` units. Never use `dp` for text —
  it breaks the system font size accessibility setting.
- **Colour-only signals:** The importance dot uses colour alone to convey
  priority. If stricter accessibility is required, supplement with a label
  or different icon shapes per level.

---

## Platform Notes

### Web (PWA)

- Manifest: `src/main/app/web/manifest.json`
- Icons: `192×192` and `512×512` in `web/icons/`
- Service Worker: auto-generated by Flutter build
- Theme colour metadata: derived from seed brand colour at build time

### Android

- Dynamic Colour: supported on Android 12+ via `dynamic_color` package
- AMOLED mode: user opt-in; sets `surface` to `#000000` instead of `#111214`
- Minimum API: follows Flutter minimum (currently API 21)

---

## Theming Architecture

```
User preference (seed colour or dynamic colour)
  │
  ↓
ColorScheme.fromSeed()          ← M3 colour algorithm
  │
  ├─ surface overrides (pinned) ← fixed neutrals overwrite seed-derived values
  │
  ↓
ThemeData(useMaterial3: true)   ← applied globally via MaterialApp.router
  │
  ├─ darkTheme  (ThemeMode.dark)
  ├─ theme      (ThemeMode.light)
  └─ themeMode: ThemeMode.system ← follows OS preference by default
```

User-selectable preferences stored in `SharedPreferences`:

| Key | Type | Default | Description |
|---|---|---|---|
| `theme-color` | int (ARGB32) | `Colors.deepOrange` | Seed colour |
| `brightness` | string | `system` | `system` / `light` / `dark` |
| `dynamic-color` | bool | `false` | Use Android 12+ dynamic colour |
| `black-background` | bool | `false` | AMOLED mode (`surface` = `#000000`) |
| `density` | double | `4.0` | Flutter visual density |
| `truncate-text` | bool | `true` | Truncate long article text |
| `title-max-lines` | int | `3` | Max lines for feed item title |
| `content-max-lines` | int | `4` | Max lines for feed item content |

---

## Related Documents

- [CLAUDE.md](CLAUDE.md) — Development rules, documentation index
- [docs/design-system.md](docs/design-system.md) — Legacy design system reference (Flutter patterns)
- [docs/frontend-patterns.md](docs/frontend-patterns.md) — BLoC, routing, services
- [docs/code-conventions.md](docs/code-conventions.md) — Dart/Flutter code style
