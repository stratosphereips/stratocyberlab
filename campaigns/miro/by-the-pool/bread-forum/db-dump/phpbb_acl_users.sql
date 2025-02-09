create table phpbb_acl_users
(
    user_id        INTEGER UNSIGNED default '0' not null,
    forum_id       INTEGER UNSIGNED default '0' not null,
    auth_option_id INTEGER UNSIGNED default '0' not null,
    auth_role_id   INTEGER UNSIGNED default '0' not null,
    auth_setting   TINYINT(2)       default '0' not null
);

create index phpbb_acl_users_auth_option_id
    on phpbb_acl_users (auth_option_id);

create index phpbb_acl_users_auth_role_id
    on phpbb_acl_users (auth_role_id);

create index phpbb_acl_users_user_id
    on phpbb_acl_users (user_id);

INSERT INTO phpbb_acl_users (user_id, forum_id, auth_option_id, auth_role_id, auth_setting) VALUES (2, 0, 0, 5, 0);
