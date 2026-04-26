-- F5: Per-user sync status so the UI can show "last synced X min ago"
-- and surface persistent sync errors. Status is tracked as a string enum
-- (SUCCESS / PARTIAL / FAILED / RUNNING) rather than a boolean to allow
-- the UI to distinguish "sync running" from "never synced".

ALTER TABLE users
    ADD COLUMN last_sync_time BIGINT,
    ADD COLUMN last_sync_status VARCHAR(20),
    ADD COLUMN last_sync_error_message TEXT;
