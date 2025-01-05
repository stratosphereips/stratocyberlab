create table phpbb_tfa_back_reg
(
    registration_id INTEGER
        primary key autoincrement,
    user_id         INTEGER UNSIGNED default '0' not null,
    secret          VARCHAR(255)     default ''  not null,
    last_used       INTEGER UNSIGNED default '0' not null,
    registered      INTEGER UNSIGNED default '0' not null,
    valid           INTEGER UNSIGNED default '0' not null
);

create index phpbb_tfa_back_reg_user_id
    on phpbb_tfa_back_reg (user_id);

