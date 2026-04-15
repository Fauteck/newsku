-- Add 'saved' flag to feed_items for reading-list / bookmark functionality
ALTER TABLE feed_items ADD COLUMN saved BOOLEAN NOT NULL DEFAULT FALSE;
