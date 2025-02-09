create table phpbb_banlist
(
    ban_id          INTEGER
        primary key autoincrement,
    ban_userid      INTEGER UNSIGNED default '0' not null,
    ban_ip          VARCHAR(40)      default ''  not null,
    ban_email       VARCHAR(100)     default ''  not null,
    ban_start       INTEGER UNSIGNED default '0' not null,
    ban_end         INTEGER UNSIGNED default '0' not null,
    ban_exclude     INTEGER UNSIGNED default '0' not null,
    ban_reason      VARCHAR(255)     default ''  not null,
    ban_give_reason VARCHAR(255)     default ''  not null
);

create index phpbb_banlist_ban_email
    on phpbb_banlist (ban_email, ban_exclude);

create index phpbb_banlist_ban_end
    on phpbb_banlist (ban_end);

create index phpbb_banlist_ban_ip
    on phpbb_banlist (ban_ip, ban_exclude);

create index phpbb_banlist_ban_user
    on phpbb_banlist (ban_userid, ban_exclude);

