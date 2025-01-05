create table phpbb_forums_watch
(
    forum_id      INTEGER UNSIGNED default '0' not null,
    user_id       INTEGER UNSIGNED default '0' not null,
    notify_status INTEGER UNSIGNED default '0' not null
);

create index phpbb_forums_watch_forum_id
    on phpbb_forums_watch (forum_id);

create index phpbb_forums_watch_notify_stat
    on phpbb_forums_watch (notify_status);

create index phpbb_forums_watch_user_id
    on phpbb_forums_watch (user_id);

