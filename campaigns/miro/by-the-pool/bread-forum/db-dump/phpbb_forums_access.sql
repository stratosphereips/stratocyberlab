create table phpbb_forums_access
(
    forum_id   INTEGER UNSIGNED default '0' not null,
    user_id    INTEGER UNSIGNED default '0' not null,
    session_id CHAR(32)         default ''  not null,
    primary key (forum_id, user_id, session_id)
);

