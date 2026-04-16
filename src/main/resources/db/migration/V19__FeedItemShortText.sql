-- AI-generated length-adapted variants of the article title and teaser.
-- Used when the global "text shortening" preference is enabled so the UI can
-- render a properly rewritten short form (not an ellipsis-truncated string)
-- in compact grid cards.
ALTER TABLE feed_items ADD COLUMN short_title  VARCHAR(255);
ALTER TABLE feed_items ADD COLUMN short_teaser VARCHAR(512);
