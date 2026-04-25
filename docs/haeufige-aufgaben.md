# Common Tasks

← [Back to Index](../CLAUDE.md)

---

## 1. New REST Endpoint + Flutter Screen (End-to-End)

### Affected Files

| File | Action |
|------|--------|
| `src/main/resources/db/migration/V{n}__*.sql` | Migration (if new table/column) |
| `src/main/java/.../persistence/entities/MyEntity.java` | JPA entity |
| `src/main/java/.../persistence/repositories/MyRepository.java` | JPA repository |
| `src/main/java/.../services/MyService.java` | Business logic |
| `src/main/java/.../controllers/MyController.java` | REST controller |
| `src/main/app/lib/my_module/models/my_model.dart` | Dart model |
| `src/main/app/lib/my_module/my_service.dart` | HTTP service |
| `src/main/app/lib/my_module/my_bloc.dart` | BLoC |
| `src/main/app/lib/my_module/my_view.dart` | Flutter screen |
| `src/main/app/lib/router.dart` | Register route |

### Steps

1. **Migration** (if new table):

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
    // Getters/setters
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

6. **Dart Model**:

```dart
class MyModel {
  final String id;
  final String name;
  const MyModel({required this.id, required this.name});
  factory MyModel.fromJson(Map<String, dynamic> json) =>
      MyModel(id: json['id'], name: json['name']);
}
```

7. **Flutter Screen + Route** (see [frontend-patterns.md](frontend-patterns.md))

---

## 2. Create New Flyway Migration

```bash
# Determine next available version number
ls src/main/resources/db/migration/

# Create file (e.g. V17)
touch src/main/resources/db/migration/V17__my_change.sql
```

```sql
-- Example: add column
ALTER TABLE feed_items ADD COLUMN reading_time_seconds INTEGER;

-- Example: new table
CREATE TABLE feed_tags (
    id VARCHAR(36) PRIMARY KEY,
    feed_id VARCHAR(36) NOT NULL REFERENCES feeds(id) ON DELETE CASCADE,
    tag VARCHAR(100) NOT NULL
);
```

Flyway runs the migration automatically on next startup.
**Never modify existing migrations retroactively.**

---

## 3. Build and Test Docker Image Locally

```bash
# Build JAR
mvn clean package -DskipTests

# Build image
docker build -t newsku:local -f docker/Dockerfile .

# Test (PostgreSQL must be running or provided via docker-compose)
docker run --rm \
  -p 8080:8080 \
  -e DB_HOST=host.docker.internal \
  -e DB_PORT=5432 \
  -e DB_DATABASE=newsku \
  -e DB_USER=newsku \
  -e DB_PASSWORD=secret \
  -e OPENAI_API_KEY=sk-test \
  -e OPENAI_MODEL=gpt-4o \
  -e SALT=test-salt-at-least-32-characters-long \
  newsku:local

# Check health
curl http://localhost:8080/actuator/health
```

---

## 4. Embed Flutter Web Build in Backend

```bash
# Create Flutter web build
cd src/main/app
flutter build web

# Copy build output to Spring Boot static directory
cp -r build/web/* ../resources/static/

# Rebuild backend
cd ../../..
mvn clean package -DskipTests
```

`StaticContentController` then serves the Flutter build when no API route matches.

---

## 5. Add New Feed Type / LLM Feature

### Adjust LLM Ranking

The LLM logic is in `src/main/java/.../services/OpenaiServiceImpl.java`:

```java
@Service
public class OpenaiServiceImpl implements OpenaiService {

    @Override
    public void rankItems(String userId, List<FeedItem> items) {
        // Build prompt with user preferences + item titles
        String prompt = buildRankingPrompt(userPreferences, items);

        // Call OpenAI API
        ChatCompletion response = openaiClient.chat().completions().create(
            ChatCompletionCreateParams.builder()
                .model(openaiModel)
                .addUserMessage(prompt)
                .build()
        );

        // Parse and apply scores
        parseAndApplyScores(response, items);
    }
}
```

---

## 6. Add New Email Template

1. **Create Freemarker template**:

```
src/main/resources/templates/email/my-template.ftl
```

2. **Extend EmailService**:

```java
// EmailService.java interface
void sendMyEmail(String toEmail, Map<String, Object> model);

// EmailServiceImpl.java
@Override
public void sendMyEmail(String toEmail, Map<String, Object> model) {
    Email email = EmailBuilder.startingBlank()
        .to(toEmail)
        .withSubject("Subject")
        .withHTMLText(renderTemplate("my-template.ftl", model))
        .buildEmail();
    mailer.sendMail(email);
}
```

---

## 7. Check Health Endpoint

```bash
# Actuator health endpoint
curl http://localhost:8080/actuator/health

# Expected response:
# { "status": "UP", "components": { "db": { "status": "UP" }, ... } }
```

---

## 8. Explore API via Swagger UI

Spring Boot automatically starts a Swagger UI:

```
http://localhost:8080/swagger-ui.html
```

All endpoints can be tested interactively there.
Enter the JWT token once at the top right (Authorize button), then call all
authenticated endpoints directly.

---

## 9. Create User Manually / Reset Password

When `ALLOW_SIGNUP=0`: users must be created manually in the database.

```sql
-- Generate password hash with BCrypt (e.g. via https://bcrypt-generator.com)
INSERT INTO users (id, email, password)
VALUES (gen_random_uuid(), 'admin@example.com', '$2a$10$...');
```

Password reset is available via email at `POST /api/reset-password`.

---

## Related Documents

- [docs/api-patterns.md](api-patterns.md) — Controller and service patterns
- [docs/frontend-patterns.md](frontend-patterns.md) — Flutter modules and screens
- [docs/datenbank.md](datenbank.md) — Schema, migrations workflow
- [docs/entwicklung.md](entwicklung.md) — Setup, build commands
