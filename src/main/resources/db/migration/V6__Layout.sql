CREATE TABLE layout_blocks
(
    id       varchar(55) primary key,
    type     varchar(55) not null,
    display_order    int         not null,
    settings jsonb,
    user_id  varchar(55) not null references users (id) on DELETE cascade
);