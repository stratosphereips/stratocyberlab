create table phpbb_topics_track
(
    user_id   INTEGER UNSIGNED default '0' not null,
    topic_id  INTEGER UNSIGNED default '0' not null,
    forum_id  INTEGER UNSIGNED default '0' not null,
    mark_time INTEGER UNSIGNED default '0' not null,
    primary key (user_id, topic_id)
);

create index phpbb_topics_track_forum_id
    on phpbb_topics_track (forum_id);

create index phpbb_topics_track_topic_id
    on phpbb_topics_track (topic_id);

INSERT INTO phpbb_topics_track (user_id, topic_id, forum_id, mark_time) VALUES (61, 3, 14, 1736079964);
INSERT INTO phpbb_topics_track (user_id, topic_id, forum_id, mark_time) VALUES (62, 3, 14, 1736080014);
INSERT INTO phpbb_topics_track (user_id, topic_id, forum_id, mark_time) VALUES (63, 3, 14, 1736080282);
