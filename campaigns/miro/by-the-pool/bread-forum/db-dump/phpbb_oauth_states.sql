create table phpbb_oauth_states
(
    user_id     INTEGER UNSIGNED default '0' not null,
    session_id  CHAR(32)         default ''  not null,
    provider    VARCHAR(255)     default ''  not null,
    oauth_state VARCHAR(255)     default ''  not null
);

create index phpbb_oauth_states_provider
    on phpbb_oauth_states (provider);

create index phpbb_oauth_states_user_id
    on phpbb_oauth_states (user_id);

