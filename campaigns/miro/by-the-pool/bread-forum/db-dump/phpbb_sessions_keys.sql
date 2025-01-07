create table phpbb_sessions_keys
(
    key_id     CHAR(32)         default ''  not null,
    user_id    INTEGER UNSIGNED default '0' not null,
    last_ip    VARCHAR(40)      default ''  not null,
    last_login INTEGER UNSIGNED default '0' not null,
    primary key (key_id, user_id)
);

create index phpbb_sessions_keys_last_login
    on phpbb_sessions_keys (last_login);

