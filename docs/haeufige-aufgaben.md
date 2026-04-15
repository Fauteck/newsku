# Haeufige Aufgaben

← [Zurueck zum Index](../CLAUDE.md)

---

## 1. Neuen REST-Endpunkt + Flutter-Screen (End-to-End)

### Betroffene Dateien

| Datei | Aktion |
|-------|--------|
| `src/main/resources/db/migration/V{n}__*.sql` | Migration (falls neue Tabelle/Spalte) |
| `src/main/java/.../persistence/entities/MeinEntity.java` | JPA Entity |
| `src/main/java/.../persistence/repositories/MeinRepository.java` | JPA Repository |
| `src/main/java/.../services/MeinService.java` | Geschaeftslogik |
| `src/main/java/.../controllers/MeinController.java` | REST Controller |
| `src/main/app/lib/mein_modul/models/mein_model.dart` | Dart Modell |
| `src/main/app/lib/mein_modul/mein_service.dart` | HTTP-Service |
| `src/main/app/lib/mein_modul/mein_bloc.dart` | BLoC |
| `src/main/app/lib/mein_modul/mein_view.dart` | Flutter Screen |
| `src/main/app/lib/router.dart` | Route registrieren |

### Schritte

1. **Migration** (falls neue Tabelle):

```sql
-- src/main/resources/db/migration/V17__create_my_table.sql
CREATE TABLE my_table (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL REFERENCES users(id),
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

2. **JPA Entity**:

```java
// src/main/java/.../persistence/entities/MyEntity.java
@Entity
@Table(name = "my_table")
public class MyEntity {
    @Id private String id;
    @Column(nullable = false) private String userId;
    @Column(nullable = false) private String name;
    private Instant createdAt;
    // Getter/Setter
}
```

3. **Repository**:

```java
@Repository
public interface MyRepository extends JpaRepository<MyEntity, String> {
    List<MyEntity> findByUserId(String userId);
}
```

4. **Service**:

```java
@Service
@Transactional
public class MyService {
    private final MyRepository myRepository;
    public MyService(MyRepository myRepository) { this.myRepository = myRepository; }

    public List<MyEntity> getAll(String userId) {
        return myRepository.findByUserId(userId);
    }
}
```

5. **Controller**:

```java
@RestController
@RequestMapping("/api/my-resource")
public class MyController {
    private final MyService myService;
    public MyController(MyService myService) { this.myService = myService; }

    @GetMapping
    public List<MyEntity> getAll(Authentication auth) {
        return myService.getAll(auth.getName());
    }
}
```

6. **Dart Modell**:

```dart
class MyModel {
  final String id;
  final String name;
  const MyModel({required this.id, required this.name});
  factory MyModel.fromJson(Map<String, dynamic> json) =>
      MyModel(id: json['id'], name: json['name']);
}
```

7. **Flutter Screen + Route** (siehe [frontend-patterns.md](frontend-patterns.md))

---

## 2. Neue Flyway-Migration anlegen

```bash
# Naechste freie Versionsnummer bestimmen
ls src/main/resources/db/migration/

# Datei anlegen (z. B. V17)
touch src/main/resources/db/migration/V17__meine_aenderung.sql
```

```sql
-- Beispiel: Neue Spalte hinzufuegen
ALTER TABLE feed_items ADD COLUMN reading_time_seconds INTEGER;

-- Beispiel: Neue Tabelle
CREATE TABLE feed_tags (
    id VARCHAR(36) PRIMARY KEY,
    feed_id VARCHAR(36) NOT NULL REFERENCES feeds(id) ON DELETE CASCADE,
    tag VARCHAR(100) NOT NULL
);
```

Flyway fuehrt die Migration beim naechsten Start automatisch aus.
**Bestehende Migrationen niemals nachtraeglich aendern.**

---

## 3. Docker-Image lokal bauen und testen

```bash
# JAR bauen
mvn clean package -DskipTests

# Image bauen
docker build -t newsku:local -f docker/Dockerfile .

# Testen (PostgreSQL muss laufen oder per docker-compose bereitgestellt werden)
docker run --rm \
  -p 8080:8080 \
  -e DB_HOST=host.docker.internal \
  -e DB_PORT=5432 \
  -e DB_DATABASE=newsku \
  -e DB_USER=newsku \
  -e DB_PASSWORD=secret \
  -e OPENAI_API_KEY=sk-test \
  -e OPENAI_MODEL=gpt-4o \
  -e SALT=test-salt-mindestens-32-zeichen-lang \
  newsku:local

# Health Check pruefen
curl http://localhost:8080/actuator/health
```

---

## 4. Flutter Web Build in Backend einbinden

```bash
# Flutter Web Build erstellen
cd src/main/app
flutter build web

# Build-Ausgabe in Spring Boot Static-Verzeichnis kopieren
cp -r build/web/* ../resources/static/

# Backend neu bauen
cd ../../..
mvn clean package -DskipTests
```

Der `StaticContentController` liefert dann den Flutter Build aus, wenn keine API-Route zutrifft.

---

## 5. Neuen Feed-Typ / neue LLM-Funktion hinzufuegen

### LLM-Ranking anpassen

Die LLM-Logik liegt in `src/main/java/.../services/OpenaiServiceImpl.java`:

```java
@Service
public class OpenaiServiceImpl implements OpenaiService {

    @Override
    public void rankItems(String userId, List<FeedItem> items) {
        // Prompt mit Benutzer-Praeferenzen + Item-Titeln aufbauen
        String prompt = buildRankingPrompt(userPreferences, items);

        // OpenAI API aufrufen
        ChatCompletion response = openaiClient.chat().completions().create(
            ChatCompletionCreateParams.builder()
                .model(openaiModel)
                .addUserMessage(prompt)
                .build()
        );

        // Scores parsen und an Items setzen
        parseAndApplyScores(response, items);
    }
}
```

---

## 6. Neues E-Mail-Template hinzufuegen

1. **Freemarker Template** erstellen:

```
src/main/resources/templates/email/mein-template.ftl
```

2. **EmailService erweitern**:

```java
// EmailService.java Interface
void sendMeinEmail(String toEmail, Map<String, Object> model);

// EmailServiceImpl.java
@Override
public void sendMeinEmail(String toEmail, Map<String, Object> model) {
    Email email = EmailBuilder.startingBlank()
        .to(toEmail)
        .withSubject("Betreff")
        .withHTMLText(renderTemplate("mein-template.ftl", model))
        .buildEmail();
    mailer.sendMail(email);
}
```

---

## 7. Health-Check pruefen

```bash
# Actuator Health-Endpunkt
curl http://localhost:8080/actuator/health

# Erwartete Antwort:
# { "status": "UP", "components": { "db": { "status": "UP" }, ... } }
```

---

## 8. API via Swagger UI erkunden

Spring Boot startet automatisch eine Swagger UI:

```
http://localhost:8080/swagger-ui.html
```

Alle Endpunkte koennen dort interaktiv getestet werden.
JWT-Token einmalig oben rechts (Authorize-Button) eingeben, dann alle Auth-Endpunkte direkt aufrufen.

---

## 9. Benutzer manuell erstellen / Passwort zuruecksetzen

Wenn `ALLOW_SIGNUP=0`: Benutzer muessen manuell in der Datenbank angelegt werden.

```sql
-- Passwort-Hash mit BCrypt generieren (z. B. via https://bcrypt-generator.com)
INSERT INTO users (id, email, password)
VALUES (gen_random_uuid(), 'admin@example.com', '$2a$10$...');
```

Passwort-Reset-Funktion ist per E-Mail erreichbar via `POST /api/reset-password`.

---

## Verwandte Dokumente

- [docs/api-patterns.md](api-patterns.md) — Controller- und Service-Muster
- [docs/frontend-patterns.md](frontend-patterns.md) — Flutter Module und Screens
- [docs/datenbank.md](datenbank.md) — Schema, Migrations-Workflow
- [docs/entwicklung.md](entwicklung.md) — Setup, Build-Befehle
