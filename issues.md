# NewsKu — Verbesserungsliste (Audit)

## Kontext

NewsKu ist ein News-/RSS-Reader (Spring Boot 4.0.1 + Flutter), der via GReader-API mit FreshRSS synchronisiert und KI-basiertes Ranking/Priorisierung über die OpenAI API liefert. Diese Liste dokumentiert konkrete Verbesserungsmöglichkeiten, Zusatzfunktionen, Effizienzsteigerungen und zu schließende Sicherheitslücken, die im Audit identifiziert wurden.

Aufwands-Skala: **XS** ≤ 1 h · **S** ≤ halber Tag · **M** 1–2 Tage · **L** 3–5 Tage · **XL** > 1 Woche.
Nutzen-Skala: **Niedrig / Mittel / Hoch / Kritisch**.

---

## Teil 1 — Backend & Security (Spring Boot)

> Scope: `src/main/java/com/github/lamarios/newsku/**`, `src/main/resources/db/migration/**`, `src/main/resources/application.yml`.
> Frontend (Flutter) und Infrastruktur (CI/CD, Docker, Docs, Monitoring) folgen in separaten Teilen.

### 🔴 Kritisch (Security)

| # | Titel | Beschreibung | Aufwand | Nutzen |
|---|---|---|---|---|
| B2 | SSRF-Schutz beim OG-Image-Fetch | `GReaderSyncService.java:445-451` ruft über `Jsoup.connect(url)` beliebige URLs aus Feed-Inhalten ab. Private IP-Ranges (127.0.0.0/8, 10/8, 172.16/12, 192.168/16, 169.254/16, ::1) blockieren, nur `http/https` zulassen, DNS-Rebinding durch Pre-Resolve + Re-Check verhindern. | M | Kritisch |
| B4 | Schwache JWT-Key-Derivation ersetzen | `JwtTokenUtil.java:46-62` erweitert den Salt durch Byte-Copy statt KDF. Auf PBKDF2WithHmacSHA512 (≥ 100 000 Iterationen) oder HKDF (z. B. via Bouncy Castle) umstellen; Schlüssel einmalig beim Startup ableiten und als `SecretKey` halten. | S | Hoch |
| B5 | `@Valid` + Bean-Constraints auf allen `@RequestBody` | Controller (`FeedController`, `SignUpController`, `UserController`) akzeptieren unvalidiertes JSON. `@Valid` ergänzen und auf Entities/DTOs `@NotBlank`, `@Email`, `@Size`, `@Pattern` (UUID-Format) setzen. Global `MethodArgumentNotValidExceptionHandler`. | M | Hoch |
| B6 | Globales API-Rate-Limiting | Derzeit nur `LoginRateLimitFilter`. Bucket4j-Filter für `/api/**` (z. B. 100 req/min/User, 30 req/min/IP für Public-Endpoints), separate Buckets für teure Endpoints (Search, Export, Sync-Trigger). | M | Hoch |
| B7 | X-Forwarded-For-Spoofing schließen | `LoginRateLimitFilter.java:75-82` vertraut jedem XFF-Header. `server.tomcat.remoteip`-Filter konfigurieren (`internalProxies`, `protocolHeader`) und im Filter `request.getRemoteAddr()` nach Tomcat-Auflösung verwenden. | S | Hoch |
| B8 | Sicherheits-Header (HSTS, CSP, X-Frame, X-Content-Type) | `WebSecurityConfig.java` setzt keine Header. `httpSecurity.headers(...)` mit HSTS (1 y, preload, includeSubDomains), `frameOptions(DENY)`, `contentTypeOptions()`, minimaler CSP für Swagger/API. | S | Mittel |
| B11 | Audit-Logging für Security-Events | Kein strukturiertes Logging für Failed Login (außer 429), Passwort-Reset, Admin-Aktionen, Ownership-Verletzungen. Eigener Logger `security-audit` mit Event-Codes + korrelierbarer `traceId`. | S | Mittel |
| B12 | CORS: Header-Whitelist statt `*` | `WebSecurityConfig.java:75-76` erlaubt `setAllowedHeaders(List.of("*"))`. Auf `Authorization, Content-Type, Accept, X-Requested-With` begrenzen; `allowCredentials` prüfen. | XS | Niedrig |
| B13 | `APP_ENCRYPTION_KEY` nicht als `System.setProperty` | `Config.java:76` legt den Schlüssel als System-Property ab (für alle Threads/Reflection lesbar). Key stattdessen in einem `@Configuration`-Bean halten und per Konstruktor-Injection an `StringCryptoConverter` übergeben. | S | Mittel |

### 🟠 Performance & Datenzugriff

| # | Titel | Beschreibung | Aufwand | Nutzen |
|---|---|---|---|---|
| B14 | N+1 in `FeedItemService.getItems()` beseitigen | `FeedItemService.java:242-269` lädt `feedService.getFeeds()` und filtert in-memory. Direktes Repository-Query mit `@EntityGraph(attributePaths={"category"})` und `WHERE user = :user AND (:feedId IS NULL OR id = :feedId)`. | M | Hoch |
| B18 | Cursor-/Keyset-Pagination für Feed-Items | `PageRequest.of(page, size)` wird bei tiefen Seiten teuer (großes OFFSET). `WHERE timeCreated < :cursor … ORDER BY timeCreated DESC LIMIT N` — passt zum bestehenden Sort und ist O(log n). | M | Mittel |
| B20 | Retention/Cleanup für Alt-Daten | Kein Cleanup für `feed_items` (unbegrenztes Wachstum), `feed_errors`, `openai_usage`, `feed_clicks`, `tag_clicks`. `DataRetentionService` mit `@Scheduled` (täglich): ungespeicherte Items > 90 d löschen, Errors > 30 d, Click-Rohdaten > 90 d aggregieren, Usage nach 12 M archivieren. Intervalle per ENV. | M | Mittel |

### 🟡 Robustheit & Qualität

| # | Titel | Beschreibung | Aufwand | Nutzen |
|---|---|---|---|---|
| B22 | `FEED_SYNC_CRON` per ENV konfigurierbar | Laut CLAUDE.md §10a Pflicht. `@Scheduled(cron = "${FEED_SYNC_CRON:0 15,35,55 * * * *}")` in `ScheduleService` verifizieren/erzwingen; in `application.yml` als Default setzen. | XS | Mittel |
| B23 | `GReaderSyncService`-Testabdeckung | Aktuell 21 Tests / 102 Klassen (~20 %). Priorität: Sync-Retry, Idempotenz (`gReaderItemId`-Dedup), Transaktions-Rollback, SSRF-Fixtures. TestContainers (Postgres) + WireMock (FreshRSS). | L | Hoch |
| B24 | Security-Testsuite | Tests gegen die verbleibenden CVEs: SSRF (B2), XFF-Spoofing (B7), Token-Bypass (B4), Ownership-Checks (403 bei fremden IDs) sowie Regressionstests für die bereits behobenen Themen (SQL-Injection, User-Enumeration, Exception-Mapping). | M | Hoch |
| B25 | Password-Reset-Token mit DB-gespeicherter Expiration | `ResetPasswordService` prüfen: Token-TTL (15–30 min) + Single-Use-Flag in DB, nicht nur im Link. | S | Mittel |
| B26 | Sensible Request-Bodies in Logs maskieren | Globaler Jackson-Serializer / Logback-Pattern-Converter für Felder `password`, `token`, `apiKey`, `authorization`. | S | Mittel |
| B27 | Dependency-Audit für `Unirest 4.7.0` | Einmalig CVE-Scan; ggf. ersetzen durch `WebClient`/`RestClient` (Spring 6/Boot 4 nativ) — reduziert auch Dependency-Footprint. | S | Niedrig |

### Kritische Dateien (Referenzpunkte)

- Security: `src/main/java/com/github/lamarios/newsku/security/{JwtTokenUtil,WebSecurityConfig,LoginRateLimitFilter}.java`
- Services: `src/main/java/com/github/lamarios/newsku/services/{FeedItemService,FeedService,UserService,GReaderSyncService,GReaderApiService,ResetPasswordService,OpenaiServiceImpl,ScheduleService}.java`
- Controller: `src/main/java/com/github/lamarios/newsku/controllers/{FeedController,FeedItemController,UserController,SignUpController}.java`
- Errors: `src/main/java/com/github/lamarios/newsku/errors/handlers/NewskuUserExceptionHandler.java`
- Persistence: `src/main/java/com/github/lamarios/newsku/persistence/converters/StringCryptoConverter.java`
- Config: `src/main/java/com/github/lamarios/newsku/Config.java`, `src/main/resources/application.yml`
- Migrationen: `src/main/resources/db/migration/V1__InitialSetup.sql` … `V31__AddMissingConstraints.sql` (bereits gesetzt: V30 Indizes, V31 UNIQUE-Constraints. Offen: `V32__DataRetentionPolicy.sql` für B20).

### Verifikation (am Ende jeder Maßnahme)

- `mvn test` + neue Security-/Integrationstests grün (TestContainers-Postgres).
- Manuell: `curl -H 'X-Forwarded-For: 1.1.1.1, <eigene-ip>' …` → Rate-Limit zählt gegen tatsächliche Client-IP (B7).
- `curl -I …` zeigt HSTS/X-Frame-Options/X-Content-Type-Options (B8).

---

## Teil 2 — Frontend (Flutter)

> Scope: `src/main/app/lib/**`, `src/main/app/pubspec.yaml`, `src/main/app/test/**`.

### 🔴 Kritisch (Security & Datenleck)

| # | Titel | Beschreibung | Aufwand | Nutzen |
|---|---|---|---|---|
| F1 | JWT in `flutter_secure_storage` statt `SharedPreferences` | `lib/base_service.dart:18`, `lib/identity/states/identity.dart:24-26, 72` speichern das Token im Klartext in `SharedPreferences` (Android/iOS auf gerooteten/jailbroken Geräten lesbar, auf Desktop trivial auslesbar). Auf `flutter_secure_storage` (Keystore/Keychain) umstellen, `IdentityCubit` und `BaseService` konsolidiert über einen `TokenStore` zugreifen lassen. | S | Kritisch |
| F2 | `print()`-Datenlecks in Reset-Password entfernen | `lib/reset-password/services/reset_password_service.dart:20` loggt die E-Mail-Adresse, `lib/reset-password/views/screens/reset_password.dart:45` loggt dekodierte JWT-Claims. In Prod-Builds landen diese auf stdout/logcat. Ersatzlos entfernen bzw. nur über `Logger` auf Level `fine` + Redaction. | XS | Hoch |
| F3 | Token-Refresh statt Hard-Logout bei 401 | `lib/base_service.dart:89-98` wirft bei 401 direkt den User aus der App. Silent-Refresh-Endpoint (oder mind. Retry mit `WWW-Authenticate`-Hinweis); Logout nur nach fehlgeschlagenem Refresh. Parallele Requests müssen denselben Refresh abwarten (Mutex). | M | Hoch |
| F4 | Certificate-Pinning für Produktions-Backend | Kein Pinning aktiv → Proxy/MITM auf kompromittiertem Netzwerk trivial. Dio/`HttpClient`-Badge mit SPKI-Pins (primär + Backup), Rotation-Prozess dokumentieren. | M | Hoch |
| F5 | `confirmDismiss: false` bei Swipe-Gesten korrigieren | `lib/feed/views/components/clickable_feed_item.dart:55-61` signalisiert die Geste, führt sie aber nicht aus — User sehen Animation, Aktion passiert nicht (oder unklar). Rückgabewert an tatsächliches Ergebnis der Mark-Read/Save-Action koppeln. | XS | Hoch |

### 🟠 Offline-Fähigkeit & Resilienz

| # | Titel | Beschreibung | Aufwand | Nutzen |
|---|---|---|---|---|
| F6 | Lokale Persistenz für Feed-Items | Kein lokaler Cache — ohne Netz ist die App nicht nutzbar. `drift` oder `isar` für `feed_items`, `feeds`, `categories`; Repository-Pattern zwischen `FeedService` und den Cubits (Cache-First mit Hintergrund-Refresh). | L | Hoch |
| F7 | Offline-Queue für Mutationen | Read/Save/Unsave gehen offline verloren. Pending-Queue (Box in Hive/Drift) mit Re-Play bei Reconnect, Konflikt-Policy „Server gewinnt bei Read-State, Client bei Save-State". | M | Mittel |
| F8 | Error-Recovery + UI-State für Such-/Feed-Fehler | `lib/feed/states/main_feed.dart:170-210`: Search-Catch loggt nur, kein UI-Feedback. `ApiError`-Typ mit `canRetry`, Empty-/Error-Widgets mit Retry-Button; `MainFeedCubit` emittiert expliziten `FeedError`-State. | S | Mittel |
| F9 | Request-Deduplizierung + Cancel-Token | Schnelles Wechseln zwischen Feeds feuert überlappende Requests; alte Antworten überschreiben neue. `CancelToken` pro Cubit-Request, neue Requests canceln vorherige. | S | Mittel |

### 🟡 UX-Features & Produkt

| # | Titel | Beschreibung | Aufwand | Nutzen |
|---|---|---|---|---|
| F10 | Share-Sheet für Artikel | Keine Share-Funktion. `share_plus` integrieren, Share-Button in Detail-View + Long-Press-Kontextmenü in der Liste, Deep-Link-Format dokumentieren. | S | Mittel |
| F11 | Push-Notifications für neue Items | Keine Benachrichtigungen. FCM (Android/Web) + APNs (iOS) oder alternativ reine Local-Notifications via Workmanager bei Background-Sync; Opt-in pro Feed. | L | Mittel |
| F12 | Biometric-Lock für App-Start | Kein Biometric-Lock. `local_auth`: optional beim App-Resume nach > N Minuten; Token bleibt in Secure Storage, UI wird gegated. | S | Mittel |
| F13 | Tag-System für Artikel | `tag_stats.dart` existiert, aber `FeedItem` hat kein `tags`-Feld. Backend-Feld ergänzen, Filter/Suche nach Tag, Tag-Vergabe per Bulk-Action. | L | Mittel |
| F14 | Lesezeit-Tracking & Completion | Keine `readDuration`/`completionPercentage`. Scroll-Progress in Detail-View messen, Persistenz, Statistik-Tab ergänzen. | M | Mittel |
| F15 | Reading-Position-Sync | `VisibilityDetector` markiert Read bei 90 %, aber kein „Weiterlesen an Position X" nach App-Wechsel. Scroll-Position pro Item speichern (SharedPreferences/Drift, evtl. Backend-Sync). | S | Mittel |
| F16 | Advanced-Suchfilter | Nur Volltextsuche. Date-Range, Feed-Filter, Gelesen-Status, Kombinationen; gespeicherte Suchen. | M | Mittel |
| F17 | Reading-List-Kollektionen | Nur binäres `saved`. Mehrere benannte Listen (wie Ordner), Reorder, Export. | M | Niedrig |
| F18 | Integration mit Pocket/Raindrop (Read-Later) | Optionale externe Sync-Ziele per OAuth; „In Pocket speichern"-Button. | L | Niedrig |

### ⚪ Accessibility (a11y)

| # | Titel | Beschreibung | Aufwand | Nutzen |
|---|---|---|---|---|
| F19 | Semantics-Labels für Icons & Bilder | Null `Semantics`-Widgets im Codebase. Mindestens auf Icon-Buttons (`clickable_feed_item.dart:94-98`, `headline.dart`, Settings-Tabs) `semanticLabel`/`Semantics(label:...)` ergänzen. | S | Hoch |
| F20 | Screen-Reader-Tests + Hit-Target-Audit | Keine a11y-Tests. `SemanticsBinding`-Tests für Hauptflows; Icons auf ≥ 48 × 48 dp prüfen und `IconButton`-Wrapper verwenden. | M | Mittel |
| F21 | High-Contrast-Mode + Textskalierung prüfen | Density-Setting existiert (`local_preferences.dart:48`), aber kein High-Contrast. Theme-Variante mit erhöhtem Kontrast, MediaQuery `textScaleFactor` durchreichen und Layout auf 200 % testen. | S | Mittel |

### 🟢 Performance

| # | Titel | Beschreibung | Aufwand | Nutzen |
|---|---|---|---|---|
| F22 | Fehlende `const`-Konstruktoren | Grob 30+ StatelessWidgets in `lib/feed/views/components/`, `lib/settings/views/tabs/` sind nicht `const`, obwohl alle Felder final sind. `flutter analyze --fatal-infos` mit `prefer_const_constructors` im `analysis_options.yaml` aktivieren und fixen. | S | Mittel |
| F23 | `buildWhen` / `context.select` einziehen | 30+ `BlocBuilder` rebuilden auf jedes State-Delta. Für `MainFeedCubit` mit großen `Map<DateTimeRange, List<FeedItem>>`-States selektive Rebuilds (Beispiel `feed_screen.dart:40-180`). | M | Mittel |
| F24 | Image-Prefetch für sichtbare + nächste Blöcke | `feed_item_image.dart:33-42` cached erst beim Rendern. `precacheImage` für das nächste Fenster im Scroll-Listener (`main_feed.dart:90-98`). | S | Mittel |
| F25 | Cache-Limits konfigurierbar | `user.dart:88-91` bietet nur manuelles Clear. `CacheManager` mit `maxNrOfCacheObjects` / `stalePeriod` via Settings; Auto-Clean bei Überschreitung. | S | Niedrig |
| F26 | State-Slicing im MainFeedCubit | Großer State-Record sorgt für viele Rebuilds & Allokationen. Aufspalten in `FeedListCubit`, `FeedFilterCubit`, `SearchCubit`; Shared-Repository dazwischen. | L | Mittel |

### 🔵 Code-Qualität & Tests

| # | Titel | Beschreibung | Aufwand | Nutzen |
|---|---|---|---|---|
| F27 | Testabdeckung anheben (~5 % → ≥ 30 %) | Nur 15 Widget-Tests, keine Unit-/BLoC-Tests. `bloc_test` für alle Cubits, `mocktail` für Services; Vertragstests für `BaseService` (401/5xx/Timeout). | L | Hoch |
| F28 | Deutsche Lokalisierung | `app_en.arb` vorhanden, `supportedLocales` nur `en`. `app_de.arb` ergänzen; UI ist laut CLAUDE.md für den Kontext deutsch. | S | Mittel |
| F29 | Error-Klassifikation in `BaseService` | `base_service.dart:75-104` liefert generische Strings. `ApiException`-Hierarchie (`NetworkError`, `AuthError`, `ValidationError`, `ServerError`) mit `canRetry`-Flag, einheitliches Error-Widget. | S | Mittel |
| F30 | `print` → `Logger` hausweit | Neben F2 auch `main.dart:22` vereinheitlichen; Lint-Regel `avoid_print` auf `error` stellen. | XS | Niedrig |
| F31 | CI: `flutter analyze` + `flutter test` als Gate | Aktuell kein Frontend-Job in CI. Workflow `flutter-ci.yml` mit `analyze`, `test`, `build_runner check`. | S | Hoch |
| F32 | Integrationstests (Golden-Path) | Keine `integration_test/`. Login → Feed laden → Item lesen → Save → Logout als Smoke-Suite auf Android-/Web-Emulator. | M | Mittel |

### Kritische Dateien (Referenzpunkte)

- Security/HTTP: `lib/base_service.dart`, `lib/identity/states/identity.dart`
- Feed-Flow: `lib/feed/states/main_feed.dart`, `lib/feed/views/screens/feed_screen.dart`, `lib/feed/views/components/clickable_feed_item.dart`, `lib/feed/views/components/feed_item_image.dart`, `lib/feed/services/feed_service.dart`
- Reset-Password: `lib/reset-password/services/reset_password_service.dart`, `lib/reset-password/views/screens/reset_password.dart`
- Settings/Preferences: `lib/settings/views/tabs/user.dart`, `lib/home/state/local_preferences.dart`
- i18n: `lib/l10n/app_en.arb`, `lib/l10n/app_localizations.dart`
- Tests: `test/`, neu `integration_test/`

### Verifikation (am Ende jeder Maßnahme)

- F1: nach Logout + App-Neustart kein Token in `shared_prefs.xml`; Token nur in Keystore/Keychain nachweisbar.
- F2/F30: `flutter run --release` + `adb logcat` / DevTools-Konsole zeigt keine Mails/JWTs.
- F3: 401-Response auf geschütztem Endpoint → automatischer Refresh + Wiederholung; User bleibt angemeldet, solange Refresh-Token gültig.
- F4: Proxy mit fremdem CA (z. B. mitmproxy) → Requests schlagen fehl, App zeigt klaren Fehler.
- F5: Swipe ausführen → Item wird tatsächlich Read/Saved, UI entspricht Backend-State nach Pull-to-Refresh.
- F6/F7: Flugmodus → App startet, letzte Feeds sichtbar, Read-Taps werden nach Reconnect synchronisiert.
- F19/F20: TalkBack (Android) / VoiceOver (iOS) navigiert Liste + Detail sinnvoll; Accessibility-Scanner ohne kritische Findings.
- F22/F23: DevTools „Performance" zeigt weniger Rebuild-Counts je Interaktion; `flutter analyze` ohne `prefer_const_constructors`-Warnings.
- F27/F31/F32: CI-Pipeline grün, Coverage-Report ≥ 30 %.

---

## Teil 3 — Infrastruktur, DB-Ops, CI/CD, Monitoring, Docs

> **Status: noch offen.** Die Issues zu Infrastruktur, Datenbank-Ops, CI/CD, Monitoring und Dokumentations-Pflichten sind in diesem Dokument **noch nicht ausgearbeitet** und werden in einer Folgeiteration ergänzt.
>
> Voraussichtlicher Scope (Platzhalter, noch nicht finalisiert): `.github/workflows/**`, `docker/Dockerfile`, `docker-compose.yml`, `pom.xml`, `src/main/resources/application.yml`, `log4j2.xml`, `docs/**`, `SECURITY.md`.
>
> Voraussichtliche Themenbereiche (ohne Detailaufwand/Nutzen-Bewertung — folgt später):
> - CI/CD & Supply Chain (Test-Gates, Dependency-Scanning, SAST, Container-Scan, SBOM)
> - Docker & Deployment (Non-Root, Multi-Stage, Resource-Limits, Secrets-Mount)
> - Observability (Actuator-Probes, Prometheus/Micrometer, strukturiertes JSON-Logging, Custom-Health, optional Tracing)
> - Doku-Pflichten nach CLAUDE.md §13/14 (SECURITY.md, deployment/backup-recovery/monitoring/configuration.md)
> - Betrieb & Wartung (automatisiertes Backup, Restore-Drill, Schlüssel-Rotation, Renovate, Actuator-Härtung)
>
> DB-Indizes (B15) und UNIQUE-Constraints (B19) sind bereits über die Migrationen V30/V31 umgesetzt. Retention (B20) verbleibt in Teil 1 und wird hier nicht dupliziert.

> **Hinweis:** Die detaillierten Issues/Bewertungen für Teil 3 **fehlen in dieser Version noch** und werden in einer Folgeiteration ergänzt.

---

## Priorisierte Umsetzungsreihenfolge (Teil 1 + 2)

1. **Security-Patches mit niedrigem Aufwand, hoher Wirkung:** B2, B7, B8, F1, F2, F5 (alle XS–S). _(B1, B3, B9 erledigt.)_
2. **Performance-Basis (Backend):** B14 (N+1). _(B15 Indizes, B16 Batching und B17 Caching erledigt.)_
3. **Kritische Produktlücken:** F6/F7 (Offline), B6 (globales Rate-Limit), B20 (Retention).
4. **Qualität & Tests:** B23/B24 (Backend-Testsuite), F27/F31/F32 (Frontend-Tests + CI-Gate).
5. **Feature-Ausbau:** F10–F18 nach Produkt-Priorität.
6. **Teil 3 (Infrastruktur/DB-Ops/CI/CD/Monitoring/Docs):** in separater Iteration — Priorisierung dort ergänzen.
