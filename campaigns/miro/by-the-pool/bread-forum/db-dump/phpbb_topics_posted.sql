create table phpbb_topics_posted
(
    user_id      INTEGER UNSIGNED default '0' not null,
    topic_id     INTEGER UNSIGNED default '0' not null,
    topic_posted INTEGER UNSIGNED default '0' not null,
    primary key (user_id, topic_id)
);

INSERT INTO phpbb_topics_posted (user_id, topic_id, topic_posted) VALUES (59, 3, 1);
INSERT INTO phpbb_topics_posted (user_id, topic_id, topic_posted) VALUES (60, 3, 1);
INSERT INTO phpbb_topics_posted (user_id, topic_id, topic_posted) VALUES (61, 3, 1);
INSERT INTO phpbb_topics_posted (user_id, topic_id, topic_posted) VALUES (62, 3, 1);
INSERT INTO phpbb_topics_posted (user_id, topic_id, topic_posted) VALUES (63, 3, 1);
