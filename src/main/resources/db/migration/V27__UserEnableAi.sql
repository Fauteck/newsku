-- Master kill-switch for AI features per user. When disabled, feed sync skips
-- all OpenAI calls and persists items without importance/tags/short-text.
-- Default TRUE so existing users keep current behaviour.

ALTER TABLE users ADD COLUMN enable_ai BOOLEAN NOT NULL DEFAULT TRUE;
