ALTER TABLE users ADD COLUMN ai_prompt_id varchar(55) references ai_prompts(id);
