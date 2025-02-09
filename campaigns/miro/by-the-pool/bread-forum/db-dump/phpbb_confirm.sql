create table phpbb_confirm
(
    confirm_id   CHAR(32)         default ''  not null,
    session_id   CHAR(32)         default ''  not null,
    confirm_type TINYINT(3)       default '0' not null,
    code         VARCHAR(8)       default ''  not null,
    seed         INTEGER UNSIGNED default '0' not null,
    attempts     INTEGER UNSIGNED default '0' not null,
    primary key (session_id, confirm_id)
);

create index phpbb_confirm_confirm_type
    on phpbb_confirm (confirm_type);

