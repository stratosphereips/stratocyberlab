create table phpbb_bookmarks
(
    topic_id INTEGER UNSIGNED default '0' not null,
    user_id  INTEGER UNSIGNED default '0' not null,
    primary key (topic_id, user_id)
);

