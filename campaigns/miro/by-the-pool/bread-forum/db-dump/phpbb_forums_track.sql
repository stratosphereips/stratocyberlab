create table phpbb_forums_track
(
    user_id   INTEGER UNSIGNED default '0' not null,
    forum_id  INTEGER UNSIGNED default '0' not null,
    mark_time INTEGER UNSIGNED default '0' not null,
    primary key (user_id, forum_id)
);

INSERT INTO phpbb_forums_track (user_id, forum_id, mark_time) VALUES (2, 14, 1736080110);
INSERT INTO phpbb_forums_track (user_id, forum_id, mark_time) VALUES (59, 14, 1736080621);
INSERT INTO phpbb_forums_track (user_id, forum_id, mark_time) VALUES (60, 14, 1736079824);
INSERT INTO phpbb_forums_track (user_id, forum_id, mark_time) VALUES (61, 14, 1736079964);
INSERT INTO phpbb_forums_track (user_id, forum_id, mark_time) VALUES (62, 14, 1736080014);
INSERT INTO phpbb_forums_track (user_id, forum_id, mark_time) VALUES (63, 14, 1736080282);
