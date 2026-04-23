-- UNIQUE constraints to guard against duplicates that can slip in via
-- concurrent GReader syncs or repeated OIDC logins (issue B19).
-- Both constraints use partial indices so legacy rows with NULL values
-- remain allowed.

-- One GReader item per feed (feed_items.freshrss_item_id is unique per
-- stream in the GReader protocol; duplicates would indicate a faulty sync).
CREATE UNIQUE INDEX IF NOT EXISTS uq_feed_items_freshrss_item_id
    ON feed_items (freshrss_item_id)
    WHERE freshrss_item_id IS NOT NULL;

-- Exactly one local user per OIDC subject claim.
CREATE UNIQUE INDEX IF NOT EXISTS uq_users_oidc_sub
    ON users (oidc_sub)
    WHERE oidc_sub IS NOT NULL;
