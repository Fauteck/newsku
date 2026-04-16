CREATE TABLE ai_prompts (
    id varchar(55) primary key,
    name varchar(255),
    content text,
    user_id varchar(55) references users(id)
);

ALTER TABLE magazine_tabs ADD COLUMN ai_prompt_id varchar(55) references ai_prompts(id);
