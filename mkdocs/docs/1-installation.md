# Installation

## Docker

Here's a sample docker compose file to install Newsku

```yaml
services:
  newsku:
    image: gonzague/newsku:latest
    container_name: newsku
    restart: always
    ports:
      - "8080:8080"
    environment:
      OPENAI_API_KEY: no-key
      OPENAI_MODEL: openai-gpt-oss:20B
      OPENAI_URL: <openai compatible server api url>
      SALT: <Random string, never change this once set>
      DB_HOST: postgres-newsku
      DB_PORT: 5432
      ALLOW_SIGNUP: 1
      DB_DATABASE: newsku
      DB_USER: postgres
      DB_PASSWORD: postgres

  postgres-newsku:
    container_name: postgres-newsku
    restart: always
    image: postgres:18
    ports:
      - "35433:5432"
    environment:
      POSTGRES_PASSWORD: postgres
      POSTGRES_USER: postgres
      POSTGRES_DB: newsku
    volumes:
      - ./newsku/db:/var/lib/postgresql
```