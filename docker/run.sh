#!/usr/bin/env bash
set -e

: "${DB_PASSWORD:?DB_PASSWORD must not be empty – check POSTGRES_PASSWORD in your .env}"
: "${SALT:?SALT must not be empty – set a random string of at least 32 characters}"
: "${APP_ENCRYPTION_KEY:?APP_ENCRYPTION_KEY must not be empty – run: openssl rand -base64 32}"

java -XX:MaxRAM=256m -XX:+UseSerialGC -jar /app/newsku.jar
