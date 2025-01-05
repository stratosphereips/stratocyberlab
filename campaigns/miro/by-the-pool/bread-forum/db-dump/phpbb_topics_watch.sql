create table phpbb_topics_watch
(
    topic_id      INTEGER UNSIGNED default '0' not null,
    user_id       INTEGER UNSIGNED default '0' not null,
    notify_status INTEGER UNSIGNED default '0' not null
);

create index phpbb_topics_watch_notify_stat
    on phpbb_topics_watch (notify_status);

create index phpbb_topics_watch_topic_id
    on phpbb_topics_watch (topic_id);

create index phpbb_topics_watch_user_id
    on phpbb_topics_watch (user_id);

