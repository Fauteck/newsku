-- Extend openai_usage into a full AI activity log so failed calls (e.g. 404 from a
-- misconfigured Ollama URL) also produce a visible row. Usage-less responses
-- from OpenAI-compatible providers like Ollama must yield a row with NULL tokens
-- rather than silently dropping the event.

ALTER TABLE openai_usage ALTER COLUMN prompt_tokens     DROP NOT NULL;
ALTER TABLE openai_usage ALTER COLUMN completion_tokens DROP NOT NULL;
ALTER TABLE openai_usage ALTER COLUMN total_tokens      DROP NOT NULL;

ALTER TABLE openai_usage ADD COLUMN status        VARCHAR(16)   NOT NULL DEFAULT 'OK';
ALTER TABLE openai_usage ADD COLUMN error_message VARCHAR(2000);
ALTER TABLE openai_usage ADD COLUMN duration_ms  INTEGER;

CREATE INDEX idx_openai_usage_status ON openai_usage (user_id, status, created_at);
