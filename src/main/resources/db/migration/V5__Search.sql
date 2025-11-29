ALTER TABLE feed_items
    ADD COLUMN search_terms tsvector
        GENERATED ALWAYS AS (
            to_tsvector(
                    'simple',
                    COALESCE(title,'') || ' ' ||
                    COALESCE(description,'') || ' ' ||
                    COALESCE(content,'')
            )
            ) STORED;


create index feed_query_index on feed_items (feed_id, importance, timecreated);
