-- Per-user OpenAI configuration: API key (encrypted), model, base URL,
-- optional text-shortening toggle and monthly token limits per use case.

ALTER TABLE users ADD COLUMN openai_api_key TEXT;
ALTER TABLE users ADD COLUMN openai_model VARCHAR(100);
ALTER TABLE users ADD COLUMN openai_url VARCHAR(512);
ALTER TABLE users ADD COLUMN enable_text_shortening BOOLEAN;
ALTER TABLE users ADD COLUMN openai_monthly_token_limit_relevance INT;
ALTER TABLE users ADD COLUMN openai_monthly_token_limit_shortening INT;
