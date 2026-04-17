-- Tracks OpenAI API consumption per user, split by use case
-- (RELEVANCE = importance/scoring, SHORTENING = shortTitle+shortTeaser).
--
-- Each row represents one successful OpenAI call. Monthly limits are enforced
-- by summing total_tokens in the current calendar month.

CREATE TABLE openai_usage (
    id                 VARCHAR(55)   PRIMARY KEY,
    user_id            VARCHAR(55)   NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    use_case           VARCHAR(32)   NOT NULL,
    model              VARCHAR(100),
    prompt_tokens      INT           NOT NULL,
    completion_tokens  INT           NOT NULL,
    total_tokens       INT           NOT NULL,
    estimated_cost_usd NUMERIC(12,6),
    created_at         BIGINT        NOT NULL
);

CREATE INDEX idx_openai_usage_user_time ON openai_usage (user_id, created_at DESC);
CREATE INDEX idx_openai_usage_user_usecase_time ON openai_usage (user_id, use_case, created_at DESC);
