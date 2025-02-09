create table phpbb_privmsgs_rules
(
    rule_id         INTEGER
        primary key autoincrement,
    user_id         INTEGER UNSIGNED default '0' not null,
    rule_check      INTEGER UNSIGNED default '0' not null,
    rule_connection INTEGER UNSIGNED default '0' not null,
    rule_string     VARCHAR(255)     default ''  not null,
    rule_user_id    INTEGER UNSIGNED default '0' not null,
    rule_group_id   INTEGER UNSIGNED default '0' not null,
    rule_action     INTEGER UNSIGNED default '0' not null,
    rule_folder_id  INT(11)          default '0' not null
);

create index phpbb_privmsgs_rules_user_id
    on phpbb_privmsgs_rules (user_id);

