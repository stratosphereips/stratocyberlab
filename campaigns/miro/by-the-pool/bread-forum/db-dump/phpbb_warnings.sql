create table phpbb_warnings
(
    warning_id   INTEGER
        primary key autoincrement,
    user_id      INTEGER UNSIGNED default '0' not null,
    post_id      INTEGER UNSIGNED default '0' not null,
    log_id       INTEGER UNSIGNED default '0' not null,
    warning_time INTEGER UNSIGNED default '0' not null
);

