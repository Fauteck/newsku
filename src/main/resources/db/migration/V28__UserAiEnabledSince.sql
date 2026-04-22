-- Tracks the UTC start-of-day (epoch ms) when a user first configured their AI
-- endpoint (API key or custom URL). The sync engine skips AI scoring for articles
-- published before this timestamp, limiting the initial bulk-import cost on fresh
-- installations.
-- NULL for existing users → no filtering, existing behaviour is unchanged.

ALTER TABLE users ADD COLUMN ai_enabled_since BIGINT;
