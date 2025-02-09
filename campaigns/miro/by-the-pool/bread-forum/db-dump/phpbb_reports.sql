create table phpbb_reports
(
    report_id                      INTEGER
        primary key autoincrement,
    reason_id                      INTEGER UNSIGNED     default '0' not null,
    post_id                        INTEGER UNSIGNED     default '0' not null,
    user_id                        INTEGER UNSIGNED     default '0' not null,
    user_notify                    INTEGER UNSIGNED     default '0' not null,
    report_closed                  INTEGER UNSIGNED     default '0' not null,
    report_time                    INTEGER UNSIGNED     default '0' not null,
    report_text                    MEDIUMTEXT(16777215) default ''  not null,
    pm_id                          INTEGER UNSIGNED     default '0' not null,
    reported_post_enable_bbcode    INTEGER UNSIGNED     default '1' not null,
    reported_post_enable_smilies   INTEGER UNSIGNED     default '1' not null,
    reported_post_enable_magic_url INTEGER UNSIGNED     default '1' not null,
    reported_post_text             MEDIUMTEXT(16777215) default ''  not null,
    reported_post_uid              VARCHAR(8)           default ''  not null,
    reported_post_bitfield         VARCHAR(255)         default ''  not null
);

create index phpbb_reports_pm_id
    on phpbb_reports (pm_id);

create index phpbb_reports_post_id
    on phpbb_reports (post_id);

