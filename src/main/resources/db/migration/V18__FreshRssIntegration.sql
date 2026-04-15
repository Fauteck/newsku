-- FreshRSS integration: per-user credentials
ALTER TABLE users ADD COLUMN freshrss_username     VARCHAR(255);
ALTER TABLE users ADD COLUMN freshrss_api_password VARCHAR(255);

-- Reference back to FreshRSS stream/subscription ID (e.g. "feed/https://...")
ALTER TABLE feeds ADD COLUMN freshrss_feed_id VARCHAR(512);

-- Reference back to FreshRSS label ID (e.g. "user/-/label/Tech")
ALTER TABLE feed_categories ADD COLUMN freshrss_category_id VARCHAR(512);

-- FreshRSS article ID (e.g. "tag:google.com,2005:reader/item/00000000ab1234ef")
-- Used for deduplication and read-status sync
ALTER TABLE feed_items ADD COLUMN freshrss_item_id VARCHAR(512);
CREATE INDEX idx_feed_items_freshrss_item_id ON feed_items (freshrss_item_id);
