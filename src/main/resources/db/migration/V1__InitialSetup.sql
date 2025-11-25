CREATE TABLE users
(
    id                   varchar(55) primary key,
    username             varchar(100) not null,
    password             varchar(255) not null,
    email                varchar(255) not null,
    feed_item_preference text         null
);

create unique index username_idx ON users (username);

CREATE TABLE feeds
(
    id                   varchar(55) primary key,
    name                 varchar(255) not null,
    description          text         null,
    url                  text         null,
    image text null,
    user_id              varchar(55)  not null references users (id) on DELETE cascade,
    feed_item_preference text         null
);

create unique index user_feed on feeds (url, user_id);

CREATE TABLE feed_items
(
    id          varchar(55) primary key,
    guid        text        not null,
    title       text,
    description text,
    content     text,
    image_url   text,
    timeCreated bigint      not null,
    importance  int,
    reasoning   text,
    feed_id     varchar(55) not null references feeds (id) on delete cascade
);

create unique index unique_feed_item on feed_items (guid, feed_id);