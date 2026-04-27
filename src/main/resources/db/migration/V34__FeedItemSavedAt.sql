-- F4: Track when each item was saved so the Saved tab can sort by
-- "most recently saved first" (which is what users expect when their
-- bookmark list grows past a few dozen items).
--
-- - Add savedAt as nullable BIGINT (epoch millis), consistent with
--   feed_items.timecreated and users.last_sync_time.
-- - Backfill existing saved items so the column is non-null wherever
--   it is meaningful: we don't know the historical save time, so we
--   reuse timecreated as the best available proxy.
-- - Add a partial index on (saved_at DESC) restricted to saved=true
--   so the new paginated saved-items query stays fast as the table
--   grows. The partial index is much smaller than a full-table index
--   because saved items are a small fraction of all items.

ALTER TABLE feed_items
    ADD COLUMN saved_at BIGINT;

UPDATE feed_items
SET saved_at = timecreated
WHERE saved = true
  AND saved_at IS NULL;

CREATE INDEX feed_items_saved_at_idx
    ON feed_items (saved_at DESC)
    WHERE saved = true;
