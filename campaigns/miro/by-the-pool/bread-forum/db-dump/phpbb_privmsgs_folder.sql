create table phpbb_privmsgs_folder
(
    folder_id   INTEGER
        primary key autoincrement,
    user_id     INTEGER UNSIGNED default '0' not null,
    folder_name VARCHAR(255)     default ''  not null,
    pm_count    INTEGER UNSIGNED default '0' not null
);

create index phpbb_privmsgs_folder_user_id
    on phpbb_privmsgs_folder (user_id);

