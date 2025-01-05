create table phpbb_sessions
(
    session_id            CHAR(32)         default ''  not null
        primary key,
    session_user_id       INTEGER UNSIGNED default '0' not null,
    session_last_visit    INTEGER UNSIGNED default '0' not null,
    session_start         INTEGER UNSIGNED default '0' not null,
    session_time          INTEGER UNSIGNED default '0' not null,
    session_ip            VARCHAR(40)      default ''  not null,
    session_browser       VARCHAR(150)     default ''  not null,
    session_forwarded_for VARCHAR(255)     default ''  not null,
    session_page          VARCHAR(255)     default ''  not null,
    session_viewonline    INTEGER UNSIGNED default '1' not null,
    session_autologin     INTEGER UNSIGNED default '0' not null,
    session_admin         INTEGER UNSIGNED default '0' not null,
    session_forum_id      INTEGER UNSIGNED default '0' not null,
    u2f_request           TEXT(65535),
    tfa_random            TEXT(65535),
    tfa_uid               INTEGER UNSIGNED default '0' not null
);

create index phpbb_sessions_session_fid
    on phpbb_sessions (session_forum_id);

create index phpbb_sessions_session_time
    on phpbb_sessions (session_time);

create index phpbb_sessions_session_user_id
    on phpbb_sessions (session_user_id);

INSERT INTO phpbb_sessions (session_id, session_user_id, session_last_visit, session_start, session_time, session_ip, session_browser, session_forwarded_for, session_page, session_viewonline, session_autologin, session_admin, session_forum_id, u2f_request, tfa_random, tfa_uid) VALUES ('4d64004f1d3636c21db10a6cd8e028b9', 64, 1736082669, 1736089047, 1736090105, '192.168.65.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:133.0) Gecko/20100101 Firefox/133.0', '', 'ucp.php?i=pm&mode=view&p=17', 1, 0, 0, 0, null, null, 0);
INSERT INTO phpbb_sessions (session_id, session_user_id, session_last_visit, session_start, session_time, session_ip, session_browser, session_forwarded_for, session_page, session_viewonline, session_autologin, session_admin, session_forum_id, u2f_request, tfa_random, tfa_uid) VALUES ('04ca12074df0926fcdbbbdfbe586a198', 2, 1736080196, 1736089253, 1736090060, '192.168.65.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:133.0) Gecko/20100101 Firefox/133.0', '', 'adm/index.php?i=acp_attachments&mode=extensions', 1, 0, 1, 0, null, null, 0);
INSERT INTO phpbb_sessions (session_id, session_user_id, session_last_visit, session_start, session_time, session_ip, session_browser, session_forwarded_for, session_page, session_viewonline, session_autologin, session_admin, session_forum_id, u2f_request, tfa_random, tfa_uid) VALUES ('3a014130ceccdc34af202e68d11e2990', 59, 1736090545, 1736090602, 1736090602, '192.168.65.1', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:133.0) Gecko/20100101 Firefox/133.0', '', 'index.php', 1, 0, 0, 0, null, null, 0);
