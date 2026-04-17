-- Per-user GReader/FreshRSS URL (previously only configurable via GREADER_URL env var)
ALTER TABLE users ADD COLUMN freshrss_url VARCHAR(512);
