CREATE TABLE magazine_tabs
(
    id                 varchar(55) primary key,
    name               varchar(255) not null,
    display_order      int          not null,
    is_public          boolean      not null default false,
    ai_preference      text,
    minimum_importance int,
    user_id            varchar(55)  not null references users (id) on DELETE cascade
);

ALTER TABLE layout_blocks
    ADD COLUMN tab_id varchar(55) references magazine_tabs (id) on DELETE cascade;
