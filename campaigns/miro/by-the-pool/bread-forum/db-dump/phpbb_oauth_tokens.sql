create table phpbb_oauth_tokens
(
    user_id     INTEGER UNSIGNED     default '0' not null,
    session_id  CHAR(32)             default ''  not null,
    provider    VARCHAR(255)         default ''  not null,
    oauth_token MEDIUMTEXT(16777215) default ''  not null
);

create index phpbb_oauth_tokens_provider
    on phpbb_oauth_tokens (provider);

create index phpbb_oauth_tokens_user_id
    on phpbb_oauth_tokens (user_id);

