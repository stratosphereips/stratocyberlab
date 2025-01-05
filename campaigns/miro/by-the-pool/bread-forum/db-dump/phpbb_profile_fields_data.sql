create table phpbb_profile_fields_data
(
    user_id             INTEGER UNSIGNED     default '0' not null
        primary key,
    pf_phpbb_interests  MEDIUMTEXT(16777215) default ''  not null,
    pf_phpbb_occupation MEDIUMTEXT(16777215) default ''  not null,
    pf_phpbb_location   VARCHAR(255)         default ''  not null,
    pf_phpbb_skype      VARCHAR(255)         default ''  not null,
    pf_phpbb_facebook   VARCHAR(255)         default ''  not null,
    pf_phpbb_icq        VARCHAR(255)         default ''  not null,
    pf_phpbb_twitter    VARCHAR(255)         default ''  not null,
    pf_phpbb_website    VARCHAR(255)         default ''  not null,
    pf_phpbb_youtube    VARCHAR(255)         default ''  not null,
    pf_phpbb_yahoo      VARCHAR(255)         default ''  not null
);

