create table phpbb_topics
(
    topic_id                  INTEGER
        primary key autoincrement,
    forum_id                  INTEGER UNSIGNED default '0' not null,
    icon_id                   INTEGER UNSIGNED default '0' not null,
    topic_attachment          INTEGER UNSIGNED default '0' not null,
    topic_reported            INTEGER UNSIGNED default '0' not null,
    topic_title               TEXT(65535)      default ''  not null,
    topic_poster              INTEGER UNSIGNED default '0' not null,
    topic_time                INTEGER UNSIGNED default '0' not null,
    topic_time_limit          INTEGER UNSIGNED default '0' not null,
    topic_views               INTEGER UNSIGNED default '0' not null,
    topic_status              TINYINT(3)       default '0' not null,
    topic_type                TINYINT(3)       default '0' not null,
    topic_first_post_id       INTEGER UNSIGNED default '0' not null,
    topic_first_poster_name   VARCHAR(255)     default ''  not null,
    topic_first_poster_colour VARCHAR(6)       default ''  not null,
    topic_last_post_id        INTEGER UNSIGNED default '0' not null,
    topic_last_poster_id      INTEGER UNSIGNED default '0' not null,
    topic_last_poster_name    VARCHAR(255)     default ''  not null,
    topic_last_poster_colour  VARCHAR(6)       default ''  not null,
    topic_last_post_subject   TEXT(65535)      default ''  not null,
    topic_last_post_time      INTEGER UNSIGNED default '0' not null,
    topic_last_view_time      INTEGER UNSIGNED default '0' not null,
    topic_moved_id            INTEGER UNSIGNED default '0' not null,
    topic_bumped              INTEGER UNSIGNED default '0' not null,
    topic_bumper              INTEGER UNSIGNED default '0' not null,
    poll_title                TEXT(65535)      default ''  not null,
    poll_start                INTEGER UNSIGNED default '0' not null,
    poll_length               INTEGER UNSIGNED default '0' not null,
    poll_max_options          TINYINT(4)       default '1' not null,
    poll_last_vote            INTEGER UNSIGNED default '0' not null,
    poll_vote_change          INTEGER UNSIGNED default '0' not null,
    topic_visibility          TINYINT(3)       default '0' not null,
    topic_delete_time         INTEGER UNSIGNED default '0' not null,
    topic_delete_reason       TEXT(65535)      default ''  not null,
    topic_delete_user         INTEGER UNSIGNED default '0' not null,
    topic_posts_approved      INTEGER UNSIGNED default '0' not null,
    topic_posts_unapproved    INTEGER UNSIGNED default '0' not null,
    topic_posts_softdeleted   INTEGER UNSIGNED default '0' not null
);

create index phpbb_topics_fid_time_moved
    on phpbb_topics (forum_id, topic_last_post_time, topic_moved_id);

create index phpbb_topics_forum_id
    on phpbb_topics (forum_id);

create index phpbb_topics_forum_id_type
    on phpbb_topics (forum_id, topic_type);

create index phpbb_topics_forum_vis_last
    on phpbb_topics (forum_id, topic_visibility, topic_last_post_id);

create index phpbb_topics_last_post_time
    on phpbb_topics (topic_last_post_time);

create index phpbb_topics_latest_topics
    on phpbb_topics (forum_id, topic_last_post_time, topic_last_post_id,
                     topic_moved_id);

create index phpbb_topics_topic_visibility
    on phpbb_topics (topic_visibility);

INSERT INTO phpbb_topics (topic_id, forum_id, icon_id, topic_attachment, topic_reported, topic_title, topic_poster, topic_time, topic_time_limit, topic_views, topic_status, topic_type, topic_first_post_id, topic_first_poster_name, topic_first_poster_colour, topic_last_post_id, topic_last_poster_id, topic_last_poster_name, topic_last_poster_colour, topic_last_post_subject, topic_last_post_time, topic_last_view_time, topic_moved_id, topic_bumped, topic_bumper, poll_title, poll_start, poll_length, poll_max_options, poll_last_vote, poll_vote_change, topic_visibility, topic_delete_time, topic_delete_reason, topic_delete_user, topic_posts_approved, topic_posts_unapproved, topic_posts_softdeleted) VALUES (3, 14, 0, 0, 0, 'Seeking Assistance with a Disruptive Individual', 59, 1736079664, 0, 1984, 1, 0, 5, 'Vigilante88', '', 9, 63, 'Zephyr', '00AA00', 'Re: Seeking Assistance with a Disruptive Individual', 1736080282, 1736080621, 0, 0, 0, '', 0, 0, 1, 0, 0, 1, 0, '', 0, 5, 0, 0);
