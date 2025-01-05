create table phpbb_login_attempts
(
    attempt_ip            VARCHAR(40)      default ''  not null,
    attempt_browser       VARCHAR(150)     default ''  not null,
    attempt_forwarded_for VARCHAR(255)     default ''  not null,
    attempt_time          INTEGER UNSIGNED default '0' not null,
    user_id               INTEGER UNSIGNED default '0' not null,
    username              VARCHAR(255)     default '0' not null,
    username_clean        VARCHAR(255)     default '0' not null
);

create index phpbb_login_attempts_att_for
    on phpbb_login_attempts (attempt_forwarded_for, attempt_time);

create index phpbb_login_attempts_att_ip
    on phpbb_login_attempts (attempt_ip, attempt_time);

create index phpbb_login_attempts_att_time
    on phpbb_login_attempts (attempt_time);

create index phpbb_login_attempts_user_id
    on phpbb_login_attempts (user_id);

