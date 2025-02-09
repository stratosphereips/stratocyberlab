create table phpbb_attachments
(
    attach_id         INTEGER
        primary key autoincrement,
    post_msg_id       INTEGER UNSIGNED default '0' not null,
    topic_id          INTEGER UNSIGNED default '0' not null,
    in_message        INTEGER UNSIGNED default '0' not null,
    poster_id         INTEGER UNSIGNED default '0' not null,
    is_orphan         INTEGER UNSIGNED default '1' not null,
    physical_filename VARCHAR(255)     default ''  not null,
    real_filename     VARCHAR(255)     default ''  not null,
    download_count    INTEGER UNSIGNED default '0' not null,
    attach_comment    TEXT(65535)      default ''  not null,
    extension         VARCHAR(100)     default ''  not null,
    mimetype          VARCHAR(100)     default ''  not null,
    filesize          INTEGER UNSIGNED default '0' not null,
    filetime          INTEGER UNSIGNED default '0' not null,
    thumbnail         INTEGER UNSIGNED default '0' not null
);

create index phpbb_attachments_filetime
    on phpbb_attachments (filetime);

create index phpbb_attachments_is_orphan
    on phpbb_attachments (is_orphan);

create index phpbb_attachments_post_msg_id
    on phpbb_attachments (post_msg_id);

create index phpbb_attachments_poster_id
    on phpbb_attachments (poster_id);

create index phpbb_attachments_topic_id
    on phpbb_attachments (topic_id);

INSERT INTO phpbb_attachments (attach_id, post_msg_id, topic_id, in_message, poster_id, is_orphan, physical_filename, real_filename, download_count, attach_comment, extension, mimetype, filesize, filetime, thumbnail) VALUES (3, 14, 0, 1, 59, 0, '59_e09531b3d562bcce937839c5920faa71', 'IMG_9651.jpg', 8, '', 'jpg', 'image/jpeg', 4636051, 1736089315, 0);
INSERT INTO phpbb_attachments (attach_id, post_msg_id, topic_id, in_message, poster_id, is_orphan, physical_filename, real_filename, download_count, attach_comment, extension, mimetype, filesize, filetime, thumbnail) VALUES (5, 17, 0, 1, 64, 0, '64_4c86a649b79d1f9a6d241e50019e0e98', 'tool.mp3', 2, '', 'mp3', 'audio/x-mpeg-3', 67, 1736090099, 0);
