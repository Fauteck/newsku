create table feed_errors (
    id varchar(55) not null  primary key,
    feed_id     varchar(55) not null references feeds (id) on delete cascade,
    url text null,
    message text not null,
    error text not null,
    time_created bigint      not null
);