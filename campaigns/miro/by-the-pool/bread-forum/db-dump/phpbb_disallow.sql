create table phpbb_disallow
(
    disallow_id       INTEGER
        primary key autoincrement,
    disallow_username VARCHAR(255) default '' not null
);

