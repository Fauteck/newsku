alter table feed_items
    add tags text[] default array[]::text[];

create table feed_clicks
(
    id          varchar(55) primary key,
    timeCreated bigint      not null,
    feed_id     varchar(55) not null references feeds (id) on delete cascade
);

create table tag_clicks
(
    id          varchar(55) primary key,
    tag         text        not null,
    timeCreated bigint      not null,
    user_id     varchar(55) not null references users (id) on DELETE cascade
);