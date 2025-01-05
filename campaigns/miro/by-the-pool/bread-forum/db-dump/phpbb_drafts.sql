create table phpbb_drafts
(
    draft_id      INTEGER
        primary key autoincrement,
    user_id       INTEGER UNSIGNED     default '0' not null,
    topic_id      INTEGER UNSIGNED     default '0' not null,
    forum_id      INTEGER UNSIGNED     default '0' not null,
    save_time     INTEGER UNSIGNED     default '0' not null,
    draft_subject TEXT(65535)          default ''  not null,
    draft_message MEDIUMTEXT(16777215) default ''  not null
);

create index phpbb_drafts_save_time
    on phpbb_drafts (save_time);

