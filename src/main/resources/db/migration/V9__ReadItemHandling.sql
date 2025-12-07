alter table users drop column dim_read_items;
alter table users add column read_item_handling varchar(50) default 'none' not null;