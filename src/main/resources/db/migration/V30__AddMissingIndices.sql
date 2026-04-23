-- Performance indices for the hot paths identified in the audit (issue B15).
-- Uses CREATE INDEX IF NOT EXISTS so this migration remains idempotent even
-- when running on instances where operators may have added some indices by
-- hand previously.

-- Foreign-key access on feed_items (feed_id) — the main filter in every
-- feed listing/search/starred query.
CREATE INDEX IF NOT EXISTS idx_feed_items_feed_id
    ON feed_items (feed_id);

-- Primary sort column for chronological views.
CREATE INDEX IF NOT EXISTS idx_feed_items_time_created
    ON feed_items (timecreated DESC);

-- Ranking query: filter by feed + importance, then sort by time desc.
CREATE INDEX IF NOT EXISTS idx_feed_items_importance
    ON feed_items (feed_id, importance DESC, timecreated DESC);

-- Read / saved flags are queried jointly in the item lists ("unread", "saved").
CREATE INDEX IF NOT EXISTS idx_feed_items_read_saved
    ON feed_items (feed_id, read, saved);

-- Feeds-by-user is called on every authenticated request.
CREATE INDEX IF NOT EXISTS idx_feeds_user_id
    ON feeds (user_id);

-- Category listing per user.
CREATE INDEX IF NOT EXISTS idx_feed_categories_user_id
    ON feed_categories (user_id);
