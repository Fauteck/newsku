alter table users
    add email_digest text[] default array[]::text[];
