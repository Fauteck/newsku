# Design System

← [Zurueck zum Index](../CLAUDE.md)

---

# Fauteck – Design System Dokumentation
> **Zweck:** Gemeinsames Design System aller Fauteck-Webanwendungen (Kassenbuch, Dashboard, Todo u. a.).
> Dieses Dokument beschreibt Design-Tokens, CSS-Klassen und HTML-Strukturen, die anwendungsübergreifend konsistent eingesetzt werden.
> Jede Anwendung liefert ihre eigene CSS-Datei (benannt nach dem Projekt), die auf denselben Tokens und Klassen basiert.
> ⚠️ **Sicherheitshinweis:** Alle Formulare mit `method="POST"` müssen in der Zielanwendung einen CSRF-Token enthalten.
> Flask: `<input type="hidden" name="csrf_token" value="{{ csrf_token() }}">` · Django: `{% csrf_token %}` · Laravel: `@csrf`
---
### Inhaltsverzeichnis
1. [Mitgelieferte Dateien](#1-mitgelieferte-dateien)
2. [Externe Abhängigkeiten](#2-externe-abhängigkeiten)
3. [Farbpalette (Design Tokens)](#3-farbpalette-design-tokens)
4. [Typografie](#4-typografie)
5. [Einbindung in eine neue Anwendung](#5-einbindung-in-eine-neue-anwendung)
6. [Desktop-Navigation (Navbar)](#6-desktop-navigation-navbar)
7. [Mobile Top Bar](#7-mobile-top-bar)
8. [Mobile Bottom Navigation](#8-mobile-bottom-navigation)
9. [Mobile „Mehr"-Bottom-Sheet](#9-mobile-mehr-bottom-sheet)
10. [Mobile Settings-Offcanvas](#10-mobile-settings-offcanvas)
11. [FAB (Floating Action Button)](#11-fab-floating-action-button)
12. [Flash-Nachrichten / Benachrichtigungen](#12-flash-nachrichten--benachrichtigungen)
13. [Footer](#13-footer)
14. [Komponenten-Bibliothek](#14-komponenten-bibliothek)
    - [KPI-Karten & KPI-Grid](#141-kpi-karten--kpi-grid)
    - [Section-Header (Akzent-Linie)](#142-section-header-akzent-linie)
    - [Cards](#143-cards)
    - [Buttons](#144-buttons)
    - [Tabellen](#145-tabellen)
    - [Chart-Header](#146-chart-header)
15. [Responsive Breakpoints](#15-responsive-breakpoints)
16. [Favicon & PWA-Assets](#16-favicon--pwa-assets)
17. [Vollständiges HTML-Grundgerüst](#17-vollständiges-html-grundgerüst)
---
### 15.1 Mitgelieferte Dateien
Pro Anwendung werden die folgenden statischen Dateien bereitgestellt (Dateinamen sind app-spezifisch):
| Datei | Zweck |
|---|---|
| `app/static/<app>-design.css` | **Standalone CSS** – alle Design-Tokens und Komponenten-Stile, kein Framework-Code |
| `app/static/<app>-base-template.html` | **Framework-agnostisches HTML-Grundgerüst** – enthält Navbar, Mobile-Nav, Footer, Platzhalter für Inhalte |
| `app/static/favicon.svg` | SVG-Favicon (app-spezifisch) |
| `app/static/manifest.json` | PWA-Manifest (app-spezifisch) |
| `app/static/icons/icon-192.png` | PWA-Icon 192 × 192 px |
| `app/static/icons/icon-512.png` | PWA-Icon 512 × 512 px |
---
### 15.2 Externe Abhängigkeiten
In den `<head>`-Bereich jeder Seite einfügen:
```html
<!-- Bootstrap 5.3.2 -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
      rel="stylesheet"
      integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN"
      crossorigin="anonymous">
<!-- Font Awesome 6.4.2 -->
<link rel="stylesheet"
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css"
      crossorigin="anonymous" referrerpolicy="no-referrer">
<!-- App Design System (NACH Bootstrap einbinden) -->
<link rel="stylesheet" href="/static/<app>-design.css">
```
Vor `</body>` einfügen:
```html
<!-- Bootstrap JS Bundle (inkl. Popper.js) -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL"
        crossorigin="anonymous"></script>
```
Optional – Chart.js (nur wenn Charts benötigt werden):
```html
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
```
---
### 15.3 Farbpalette (Design Tokens)
Alle Farben sind als CSS-Custom-Properties definiert und können global überschrieben werden:
```css
:root {
    /* Primäre Akzentfarbe – Navbar-Gradient, Links, Borders */
    --primary-color:   #3498db;
    /* Navbar-Hintergrund, Footer, Offcanvas-Header */
    --secondary-color: #2c3e50;
    /* Positive Werte, FAB-Button, Erfolgs-Alerts */
    --success-color:   #2ecc71;
    /* Negative Werte, Fehler-Alerts */
    --danger-color:    #e74c3c;
    /* Warnungen */
    --warning-color:   #f39c12;
    /* Info-Hinweise */
    --info-color:      #3498db;
    /* Seitenhintergrund */
    --bg-page:         #f8f9fa;
    /* Kartenhintergrund */
    --bg-card:         #ffffff;
    /* Primärer Text */
    --text-primary:    #212529;
    /* Sekundärer / gedimmter Text */
    --text-muted:      #6c757d;
    /* Standard-Rahmenfarbe */
    --border-color:    #e9ecef;
    /* Border-Radius */
    --border-radius-card: 10px;
    --border-radius-kpi:  12px;
}
```
#### Anpassung des Farbschemas
Um das Farbschema für eine andere Anwendung anzupassen, reicht es aus, die CSS-Custom-Properties zu überschreiben:
```css
/* Beispiel: Grünes Farbschema */
:root {
    --primary-color:   #27ae60;
    --secondary-color: #1a5c38;
    --success-color:   #2ecc71;
}
```
---
### 15.4 Typografie
```css
/* Schriftfamilie */
font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
/* Schriftgrößen-Hierarchie */
h1        → Bootstrap-Standard (~2rem)
h2        → Bootstrap-Standard (~1.5rem) | mobil: 1.3rem
h3        → Bootstrap-Standard (~1.25rem) | mobil: 1.1rem
/* Navbar-Brand */          font-size: 1.3rem;  font-weight: bold;
/* Mobile Top Bar Brand */  font-size: 1.1rem;  font-weight: bold;
/* Navbar-Links */          font-size: 0.875rem;
/* KPI-Label */             font-size: 0.8rem;  text-transform: uppercase;
/* KPI-Wert */              font-size: 1.5rem;  font-weight: 700;
/* KPI-Subtext */           font-size: 0.75rem;
/* Table-Header */          font-size: 0.85rem; text-transform: uppercase;
/* Bottom-Nav-Label */      font-size: 0.65rem;
```
---
### 15.5 Einbindung in eine neue Anwendung
#### Minimale HTML-Seite
```html
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Meine App</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
          rel="stylesheet"
          integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN"
          crossorigin="anonymous">
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css"
          crossorigin="anonymous" referrerpolicy="no-referrer">
    <link rel="stylesheet" href="/static/<app>-design.css">
</head>
<body>
    <!-- Navbar (Desktop) -->
    <nav class="navbar navbar-expand navbar-dark">
        <div class="container-fluid">
            <a class="navbar-brand" href="/">Meine App</a>
            <div class="navbar-collapse">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="navbar-link active" href="/">Home</a>
                    </li>
                    <li class="nav-item">
                        <a class="navbar-link" href="/berichte">Berichte</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>
    <!-- Mobile Top Bar -->
    <div class="mobile-topbar">
        <button class="mobile-topbar-btn" data-bs-toggle="offcanvas"
                data-bs-target="#mobileSettingsSheet" aria-label="Menu">
            <i class="fas fa-cog"></i>
        </button>
        <span class="mobile-topbar-brand">Meine App</span>
        <a href="/suche" class="mobile-topbar-btn" aria-label="Suche">
            <i class="fas fa-search"></i>
        </a>
    </div>
    <!-- Mobile Settings Offcanvas -->
    <div class="offcanvas offcanvas-end" tabindex="-1" id="mobileSettingsSheet"
         style="max-width: 300px;">
        <div class="offcanvas-header"
             style="background: var(--secondary-color); color: white;">
            <h5 class="offcanvas-title"><i class="fas fa-cog me-2"></i>Einstellungen</h5>
            <button type="button" class="btn-close btn-close-white"
                    data-bs-dismiss="offcanvas"></button>
        </div>
        <div class="offcanvas-body p-0">
            <div class="p-3">
                <div class="list-group list-group-flush">
                    <a href="/einstellungen" class="list-group-item list-group-item-action py-2">
                        Einstellungen
                    </a>
                </div>
            </div>
        </div>
    </div>
    <!-- Mobile Bottom Navigation -->
    <nav class="bottom-nav">
        <a class="bottom-nav-item active" href="/">
            <i class="fas fa-home"></i>
            <span>Home</span>
        </a>
        <a class="bottom-nav-item" href="/berichte">
            <i class="fas fa-chart-bar"></i>
            <span>Berichte</span>
        </a>
        <button class="bottom-nav-item"
                data-bs-toggle="offcanvas" data-bs-target="#mobileMoreSheet">
            <i class="fas fa-bars"></i>
            <span>Menu</span>
        </button>
    </nav>
    <!-- Mobile "Mehr"-Bottom-Sheet -->
    <div class="offcanvas offcanvas-bottom more-sheet" tabindex="-1" id="mobileMoreSheet"
         style="height: auto; max-height: 80vh; border-radius: 16px 16px 0 0;">
        <div class="offcanvas-header"
             style="background: var(--secondary-color); color: white; border-radius: 16px 16px 0 0;">
            <h5 class="offcanvas-title">Meine App</h5>
            <button type="button" class="btn-close btn-close-white"
                    data-bs-dismiss="offcanvas"></button>
        </div>
        <div class="offcanvas-body p-0">
            <div class="list-group list-group-flush">
                <a href="/einstellungen"
                   class="list-group-item list-group-item-action">Einstellungen</a>
            </div>
        </div>
    </div>
    <!-- Hauptinhalt -->
    <main class="container-fluid py-3">
        <h2>Willkommen</h2>
        <p>Seiteninhalt hier einfuegen.</p>
    </main>
    <!-- Footer -->
    <footer class="footer mt-5">
        <div class="container">
            <div class="col-12 text-center">
                <p class="mb-0">
                    <a href="https://github.com/mein-projekt" target="_blank" rel="noopener">
                        Meine App 2026
                    </a>
                </p>
            </div>
        </div>
    </footer>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"
            integrity="sha384-C6RzsynM9kWDrMNeT87bh95OGNyZPhcTNXj1NW7RuBCsyN/o0jlpcV8Qyq46cDfL"
            crossorigin="anonymous"></script>
</body>
</html>
```
---
### 15.6 Desktop-Navigation (Navbar)
**Erscheint bei:** Viewport-Breite > 992 px
**Hintergrund:** Linearer Gradient von `#3498db` (links) nach `#2c3e50` (rechts)
**Position:** sticky top (bleibt beim Scrollen sichtbar)
```html
<nav class="navbar navbar-expand navbar-dark">
    <div class="container-fluid">
        <!-- Brand / Logo -->
        <a class="navbar-brand" href="/">App-Name</a>
        <div class="navbar-collapse">
            <!-- Linke Navigations-Links -->
            <ul class="navbar-nav me-auto">
                <li class="nav-item">
                    <!-- Klasse "active" fuer aktive Seite setzen -->
                    <a class="navbar-link active" href="/seite1">Seite 1</a>
                </li>
                <li class="nav-item">
                    <a class="navbar-link" href="/seite2">Seite 2</a>
                </li>
            </ul>
            <!-- Rechte Elemente: Suche + User-Dropdown -->
            <ul class="navbar-nav ms-auto">
                <li class="nav-item">
                    <a class="navbar-link" href="/suche" aria-label="Suche">
                        <i class="fas fa-search"></i>
                    </a>
                </li>
                <li class="nav-item dropdown">
                    <a class="navbar-link dropdown-toggle" href="#"
                       role="button" data-bs-toggle="dropdown">
                        Max Mustermann
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><a class="dropdown-item" href="/einstellungen">Einstellungen</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li>
                            <!-- CSRF-Token hinzufuegen: Flask: {{ csrf_token() }}, Django: {% csrf_token %} -->
                            <form method="POST" action="/logout">
                                <button type="submit" class="dropdown-item">
                                    <i class="fas fa-sign-out-alt"></i> Logout
                                </button>
                            </form>
                        </li>
                    </ul>
                </li>
            </ul>
        </div>
    </div>
</nav>
```
#### CSS-Schluesselregeln
| Klasse | Beschreibung |
|---|---|
| `.navbar` | Gradient-Hintergrund, sticky, box-shadow |
| `.navbar-brand` | Weiss, bold, 1.3 rem |
| `.navbar-link` | Halbtransparentes Weiss, Hover: leichte Hinterlegung |
| `.navbar-link.active` | Staerkere Hinterlegung (`rgba(255,255,255,0.2)`) |
| `.navbar .dropdown-menu` | Dunkler Hintergrund (`--secondary-color`) |
| `.navbar .dropdown-item` | Halbtransparentes Weiss |
---
### 15.7 Mobile Top Bar
**Erscheint bei:** Viewport-Breite <= 992 px
**Hoehe:** 56 px
**Position:** Fixed top (setzt `padding-top: 56px` am `<body>`)
```html
<div class="mobile-topbar">
    <!-- Links: Einstellungs-/Menu-Button -->
    <button class="mobile-topbar-btn"
            data-bs-toggle="offcanvas"
            data-bs-target="#mobileSettingsSheet"
            aria-label="Einstellungen">
        <i class="fas fa-cog"></i>
    </button>
    <!-- Mitte: App-Name -->
    <span class="mobile-topbar-brand">App-Name</span>
    <!-- Rechts: Suche (oder anderer kontextueller Button) -->
    <a href="/suche" class="mobile-topbar-btn" aria-label="Suche">
        <i class="fas fa-search"></i>
    </a>
</div>
```
#### Wichtig
Der `<body>` erhaelt durch den Media-Query automatisch `padding-top: 56px`, damit der Inhalt nicht unter der Fixed-Bar verschwindet.
---
### 15.8 Mobile Bottom Navigation
**Erscheint bei:** Viewport-Breite <= 992 px
**Hoehe:** 60 px
**Position:** Fixed bottom (setzt `padding-bottom: 60px` am `<body>`)
**Empfehlung:** Maximal 4 Eintraege; letzter Eintrag oeffnet den „Mehr"-Bottom-Sheet.
```html
<nav class="bottom-nav">
    <!-- Aktiver Eintrag: Klasse "active" hinzufuegen -->
    <a class="bottom-nav-item active" href="/home">
        <i class="fas fa-home"></i>
        <span>Home</span>
    </a>
    <a class="bottom-nav-item" href="/ausgaben">
        <i class="fas fa-receipt"></i>
        <span>Ausgaben</span>
    </a>
    <a class="bottom-nav-item" href="/einnahmen">
        <i class="fas fa-piggy-bank"></i>
        <span>Einnahmen</span>
    </a>
    <!-- Letzter Punkt oeffnet Bottom-Sheet mit weiteren Links -->
    <button class="bottom-nav-item"
            data-bs-toggle="offcanvas"
            data-bs-target="#mobileMoreSheet">
        <i class="fas fa-bars"></i>
        <span>Menu</span>
    </button>
</nav>
```
#### Aktiv-Status setzen
Der aktive Eintrag erhaelt:
- Text-Farbe: `white` (statt 50 % Transparenz)
- Icon-Farbe: `var(--primary-color)` (Blau)
---
### 15.9 Mobile „Mehr"-Bottom-Sheet
Das Offcanvas-Element schiebt sich von unten ein und enthaelt alle Menuepunkte, die nicht in die Bottom Nav passen.
```html
<div class="offcanvas offcanvas-bottom more-sheet"
     tabindex="-1"
     id="mobileMoreSheet"
     style="height: auto; max-height: 80vh; border-radius: 16px 16px 0 0;">
    <!-- Header mit App-Name -->
    <div class="offcanvas-header"
         style="background: var(--secondary-color); color: white; border-radius: 16px 16px 0 0;">
        <h5 class="offcanvas-title">App-Name</h5>
        <button type="button" class="btn-close btn-close-white"
                data-bs-dismiss="offcanvas"></button>
    </div>
    <!-- Link-Liste -->
    <div class="offcanvas-body p-0">
        <div class="list-group list-group-flush">
            <!-- Aktiver Eintrag: Klasse "active" hinzufuegen -->
            <a href="/berichte"
               class="list-group-item list-group-item-action active">
                Berichte
            </a>
            <a href="/vermoegen"
               class="list-group-item list-group-item-action">
                Vermoegen
            </a>
            <a href="/einstellungen"
               class="list-group-item list-group-item-action">
                Einstellungen
            </a>
        </div>
    </div>
</div>
```
---
### 15.10 Mobile Settings-Offcanvas
Schiebt sich von rechts ein (max. 300 px breit). Enthaelt Einstellungs-Links und einen Logout-Button.
```html
<div class="offcanvas offcanvas-end"
     tabindex="-1"
     id="mobileSettingsSheet"
     style="max-width: 300px;">
    <div class="offcanvas-header"
         style="background: var(--secondary-color); color: white;">
        <h5 class="offcanvas-title"><i class="fas fa-cog me-2"></i>Einstellungen</h5>
        <button type="button" class="btn-close btn-close-white"
                data-bs-dismiss="offcanvas"></button>
    </div>
    <div class="offcanvas-body p-0">
        <div class="p-3">
            <!-- Optionaler Benutzername -->
            <p class="text-muted small mb-2 fw-bold text-uppercase"
               style="letter-spacing: 0.5px;">Max Mustermann</p>
            <div class="list-group list-group-flush">
                <a href="/einstellungen/logs"
                   class="list-group-item list-group-item-action py-2">Logs</a>
                <a href="/einstellungen/kategorien"
                   class="list-group-item list-group-item-action py-2">Kategorien</a>
                <a href="/einstellungen/benutzer"
                   class="list-group-item list-group-item-action py-2">Benutzer</a>
            </div>
        </div>
        <!-- Logout-Button -->
        <div class="p-3 border-top">
            <!-- CSRF-Token hinzufuegen: Flask: {{ csrf_token() }}, Django: {% csrf_token %} -->
            <form method="POST" action="/logout">
                <button type="submit" class="btn btn-outline-danger w-100">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </button>
            </form>
        </div>
    </div>
</div>
```
---
### 15.11 FAB (Floating Action Button)
**Erscheint bei:** Viewport-Breite <= 992 px
**Position:** 74 px ueber dem Bottom-Nav (rechts unten)
**Farbe:** `var(--success-color)` = `#2ecc71` (Gruen)
```html
<!-- FAB: oeffnet ein Modal oder fuehrt eine primaere Aktion aus -->
<button class="fab-btn" data-bs-toggle="modal" data-bs-target="#neuerEintragModal"
        aria-label="Neuer Eintrag">
    <i class="fas fa-plus"></i>
</button>
```
> Der FAB wird per CSS (`display: none; display: flex;` via Media Query) nur auf Mobilgeraeten angezeigt. Auf dem Desktop gibt es stattdessen einen `.primary-action-btn` (normaler Button in der Seite).
---
### 15.12 Flash-Nachrichten / Benachrichtigungen
**Position:** Oben rechts (Desktop) / Obere volle Breite (Mobil)
**Verfuegbare Kategorien:** `success`, `danger`, `warning`, `info`
```html
<div class="flash-messages">
    <!-- Erfolgs-Meldung -->
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="fas fa-check-circle me-2"></i>Aenderungen wurden gespeichert.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <!-- Fehler-Meldung -->
    <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="fas fa-exclamation-circle me-2"></i>Fehler beim Speichern.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <!-- Warnungs-Meldung -->
    <div class="alert alert-warning alert-dismissible fade show" role="alert">
        <i class="fas fa-exclamation-triangle me-2"></i>Achtung: Daten pruefen.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</div>
```
---
### 15.13 Footer
**Hintergrund:** `var(--secondary-color)` = `#2c3e50`
**Textfarbe:** `rgba(255,255,255,0.7)` (gedimmt)
**Margin-top:** 4 rem (oder `mt-5`)
```html
<footer class="footer mt-5">
    <div class="container">
        <div class="col-12 text-center">
            <p class="mb-0">
                <a href="https://github.com/mein-user/mein-projekt"
                   target="_blank" rel="noopener">
                    App-Name@Organisation 2026
                </a>
            </p>
        </div>
    </div>
</footer>
```
---
### 15.14 Komponenten-Bibliothek
#### 15.14.1 KPI-Karten & KPI-Grid
```html
<!-- KPI-Grid: 2 Spalten mobil, 3 ab md, 4 ab xl -->
<div class="kpi-grid">
    <!-- Standard KPI-Karte -->
    <div class="kpi-card">
        <div class="kpi-label">
            <i class="fas fa-euro-sign"></i> Einnahmen
        </div>
        <div class="kpi-value positive">3.450,00 EUR</div>
        <div class="kpi-sub">im aktuellen Monat</div>
    </div>
    <!-- KPI mit negativem Wert -->
    <div class="kpi-card">
        <div class="kpi-label">
            <i class="fas fa-shopping-cart"></i> Ausgaben
        </div>
        <div class="kpi-value negative">-1.200,00 EUR</div>
        <div class="kpi-sub">im aktuellen Monat</div>
    </div>
    <!-- Klickbare KPI-Karte (oeffnet Detail-Ansicht) -->
    <div class="kpi-card clickable" tabindex="0"
         onclick="window.location='/details'">
        <div class="kpi-label">
            <i class="fas fa-piggy-bank"></i> Ersparnis
        </div>
        <div class="kpi-value">2.250,00 EUR</div>
        <div class="kpi-sub">Details anzeigen</div>
    </div>
</div>
<!-- 5-spaltig ab xl: kpi-grid cols-5 -->
<div class="kpi-grid cols-5">
    <!-- 5 KPI-Karten -->
</div>
```
**Wert-Farben:**
- `.kpi-value.positive` → Gruen (`--success-color`)
- `.kpi-value.negative` → Rot (`--danger-color`)
- (kein Modifier) → Dunkel (`--text-primary`)
---
#### 15.14.2 Section-Header (Akzent-Linie)
Blauer linker Rand, grauer Hintergrund – zur Abschnittsueberschrift.
```html
<!-- Einfacher Section-Header -->
<div class="section-header">
    <h5><i class="fas fa-list me-2"></i>Mein Abschnitt</h5>
</div>
<!-- Section-Header mit Button rechts -->
<div class="section-header d-flex justify-content-between align-items-center">
    <h5><i class="fas fa-chart-bar me-2"></i>Statistiken</h5>
    <div class="section-header-right">
        <button class="btn btn-sm btn-primary">
            <i class="fas fa-plus"></i> Hinzufuegen
        </button>
    </div>
</div>
```
---
#### 15.14.3 Cards
```html
<!-- Standard-Karte -->
<div class="card">
    <div class="card-header">
        <i class="fas fa-info-circle me-2"></i>Titel
    </div>
    <div class="card-body">
        Inhalt der Karte.
    </div>
</div>
```
---
#### 15.14.4 Buttons
Bootstrap-Buttons werden minimal erweitert (leichtes Hover-Lift):
```html
<!-- Standard-Buttons -->
<button class="btn btn-primary">Primaer</button>
<button class="btn btn-success">Erfolg</button>
<button class="btn btn-danger">Loeschen</button>
<button class="btn btn-outline-secondary">Abbrechen</button>
<!-- Kleiner Button -->
<button class="btn btn-sm btn-primary">Klein</button>
```
> Auf Mobilgeraeten (<= 768 px) erhalten Buttons automatisch `min-height: 44px` und `min-width: 44px` fuer bessere Touch-Ziele.
---
#### 15.14.5 Tabellen
```html
<div class="table-section">
    <div class="card">
        <div class="card-body">
            <table class="table table-hover">
                <!-- Dunkler Header -->
                <thead>
                    <tr>
                        <th>Datum</th>
                        <th>Beschreibung</th>
                        <th class="text-end">Betrag</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>01.03.2026</td>
                        <td>Supermarkt</td>
                        <td class="text-end">45,30 EUR</td>
                    </tr>
                </tbody>
                <!-- Summenzeile -->
                <tfoot>
                    <tr class="table-total">
                        <td colspan="2"><strong>Gesamt</strong></td>
                        <td class="text-end"><strong>45,30 EUR</strong></td>
                    </tr>
                </tfoot>
            </table>
        </div>
    </div>
</div>
```
---
#### 15.14.6 Chart-Header
Header-Leiste ueber einem Chart.js-Canvas.
```html
<div class="chart-header mb-3">
    <h5><i class="fas fa-chart-line me-2"></i>Monatsverlauf</h5>
    <!-- Optionale Zeitraum-Buttons -->
    <div class="btn-group btn-group-sm">
        <button class="btn btn-outline-secondary active">12M</button>
        <button class="btn btn-outline-secondary">24M</button>
        <button class="btn btn-outline-secondary">Gesamt</button>
    </div>
</div>
<canvas id="meinChart" height="300"></canvas>
```
---
### 15.15 Responsive Breakpoints
| Breakpoint | Breite | Verhalten |
|---|---|---|
| Desktop | > 992 px | Desktop-Navbar sichtbar; Mobile-Elemente ausgeblendet |
| Tablet/Mobil | <= 992 px | Desktop-Navbar ausgeblendet; Mobile Top Bar + Bottom Nav + FAB sichtbar; `body` erhaelt `padding-top: 56px; padding-bottom: 60px` |
| Tablet | <= 768 px | Buttons: min 44 px Hoehe/Breite; Card-Padding reduziert; Tabellen-Schrift kleiner; Charts: max-height 250 px |
| Smartphone | <= 576 px | `container-fluid` enger; `h2` → 1.3 rem; `h3` → 1.1 rem |
| Smartphone klein | <= 575.98 px | Fullscreen-Modals scrollen korrekt (Flex-Fix) |
#### Sub-Navigation (Feature-spezifisch)
Einige Seiten haben eine zweite Navigationsleiste direkt unter der Haupt-Navbar.
Diese wird mit der Klasse `.sub-navbar` markiert und auf Mobilgeraeten ausgeblendet:
```html
<nav class="sub-navbar navbar navbar-expand-lg">
    <!-- Sub-Navigation Inhalt -->
</nav>
```
```css
@media (max-width: 991.98px) {
    .sub-navbar { display: none !important; }
}
```
---
### 15.16 Favicon & PWA-Assets
Favicon und PWA-Icons sind **app-spezifisch** und werden nicht geteilt. Jede Anwendung verwendet ein eigenes Icon, das zum Thema der App passt.
#### favicon.svg (Beispiel: Kassenbuch)
```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <!-- Hintergrund: Buch-Form -->
  <rect x="2" y="4" width="24" height="24" rx="2" fill="#2c3e50"/>
  <!-- Buchseiten -->
  <rect x="4" y="7" width="20" height="18" rx="1" fill="#f8f9fa"/>
  <!-- Buchbindung -->
  <rect x="4" y="7" width="3" height="18" fill="#3498db"/>
  <!-- Euro-Symbol -->
  <text x="18" y="22" font-family="Arial, sans-serif" font-size="14"
        font-weight="bold" fill="#2ecc71">EUR</text>
  <!-- Geld-Schein oben rechts -->
  <rect x="18" y="8" width="4" height="3" fill="#27ae60" rx="0.5"/>
</svg>
```
#### manifest.json
```json
{
  "name": "App-Name",
  "short_name": "App-Name",
  "description": "App-Beschreibung",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#2c3e50",
  "theme_color": "#3498db",
  "orientation": "portrait-primary",
  "icons": [
    {
      "src": "/static/icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "/static/icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any maskable"
    }
  ],
  "categories": ["productivity"],
  "lang": "de"
}
```
---
### 15.17 Vollstaendiges HTML-Grundgeruest
Fuer eine fertige, sofort verwendbare Vorlage siehe:
```
app/static/<app>-base-template.html
```
Diese Datei enthaelt das vollstaendige HTML mit allen Platzhaltern (`{{APP_NAME}}`, `{{NAV_LINKS}}` usw.) und erklaert im HTML-Kommentar, welche Variablen ersetzt werden muessen.
---
### Zusammenfassung der CSS-Klassen
| Klasse | Einsatzort |
|---|---|
| `.navbar` | Desktop-Navbar (Gradient-Hintergrund) |
| `.navbar-brand` | App-Name in der Navbar |
| `.navbar-link` | Navigations-Links in der Navbar |
| `.navbar-link.active` | Aktuell aktiver Navigations-Link |
| `.mobile-topbar` | Mobile Kopfleiste (fixed top, mobil) |
| `.mobile-topbar-brand` | App-Name in der mobilen Kopfleiste |
| `.mobile-topbar-btn` | Icons/Buttons in der mobilen Kopfleiste |
| `.bottom-nav` | Mobile Bottom-Navigation (fixed bottom) |
| `.bottom-nav-item` | Einzelner Tab in der Bottom-Navigation |
| `.bottom-nav-item.active` | Aktiver Tab |
| `.more-sheet` | Offcanvas „Mehr"-Bottom-Sheet |
| `.fab-btn` | Floating Action Button (mobil) |
| `.flash-messages` | Container fuer Toast-Benachrichtigungen |
| `.footer` | Footer-Bereich |
| `.kpi-grid` | Responsives Raster fuer KPI-Karten |
| `.kpi-grid.cols-5` | 5-spaltiges KPI-Raster (nur ab xl) |
| `.kpi-card` | KPI-Karte |
| `.kpi-card.clickable` | Klickbare KPI-Karte |
| `.kpi-label` | Beschriftung in der KPI-Karte |
| `.kpi-value` | Zahlenwert in der KPI-Karte |
| `.kpi-value.positive` | Gruener Zahlenwert |
| `.kpi-value.negative` | Roter Zahlenwert |
| `.kpi-sub` | Subtext in der KPI-Karte |
| `.section-header` | Abschnittsueberschrift mit blauer Akzent-Linie |
| `.section-header-right` | Rechter Bereich des Section-Headers |
| `.table-section` | Container fuer Tabellen mit einheitlichem Styling |
| `.table-total` | Summenzeile in Tabellen |
| `.chart-header` | Header ueber einem Chart.js-Canvas |
| `.content-section` | Allgemeiner Abstands-Wrapper |
| `.sub-navbar` | Feature-spezifische Sub-Navigation (desktop only) |
| `.primary-action-btn` | Primaerer Aktionsbutton (nur Desktop, mobil hidden) |

---
