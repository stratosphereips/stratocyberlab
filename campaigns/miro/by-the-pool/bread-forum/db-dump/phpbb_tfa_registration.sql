create table phpbb_tfa_registration
(
    registration_id INTEGER
        primary key autoincrement,
    user_id         INTEGER UNSIGNED default '0' not null,
    key_handle      VARCHAR(255)     default ''  not null,
    public_key      VARCHAR(255)     default ''  not null,
    certificate     TEXT(65535)      default ''  not null,
    counter         INTEGER UNSIGNED default '0' not null,
    last_used       INTEGER UNSIGNED default '0' not null,
    registered      INTEGER UNSIGNED default '0' not null
);

create index phpbb_tfa_registration_user_id
    on phpbb_tfa_registration (user_id);

