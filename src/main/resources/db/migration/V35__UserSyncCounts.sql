-- Quick-win #15: per-user sync counts so the UI can show
-- "Sync abgeschlossen — X neue Artikel" after a manual sync.
-- Both columns reflect the LAST sync run; they overwrite on each run.

ALTER TABLE users
    ADD COLUMN last_sync_items_added INTEGER,
    ADD COLUMN last_sync_items_updated INTEGER;
