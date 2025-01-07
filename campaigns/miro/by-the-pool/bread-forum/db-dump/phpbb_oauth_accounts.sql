create table phpbb_oauth_accounts
(
    user_id           INTEGER UNSIGNED default '0' not null,
    provider          VARCHAR(255)     default ''  not null,
    oauth_provider_id TEXT(65535)      default ''  not null,
    primary key (user_id, provider)
);

