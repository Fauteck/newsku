CREATE TABLE password_reset_tokens (
    request_id  VARCHAR(36)  NOT NULL PRIMARY KEY,
    user_id     VARCHAR(36)  NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    expires_at  TIMESTAMP    NOT NULL,
    used_at     TIMESTAMP
);

CREATE INDEX idx_prt_user_id ON password_reset_tokens(user_id);
