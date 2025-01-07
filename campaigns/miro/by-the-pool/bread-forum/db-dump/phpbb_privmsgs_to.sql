create table phpbb_privmsgs_to
(
    msg_id       INTEGER UNSIGNED default '0' not null,
    user_id      INTEGER UNSIGNED default '0' not null,
    author_id    INTEGER UNSIGNED default '0' not null,
    pm_deleted   INTEGER UNSIGNED default '0' not null,
    pm_new       INTEGER UNSIGNED default '1' not null,
    pm_unread    INTEGER UNSIGNED default '1' not null,
    pm_replied   INTEGER UNSIGNED default '0' not null,
    pm_marked    INTEGER UNSIGNED default '0' not null,
    pm_forwarded INTEGER UNSIGNED default '0' not null,
    folder_id    INT(11)          default '0' not null
);

create index phpbb_privmsgs_to_author_id
    on phpbb_privmsgs_to (author_id);

create index phpbb_privmsgs_to_msg_id
    on phpbb_privmsgs_to (msg_id);

create index phpbb_privmsgs_to_usr_flder_id
    on phpbb_privmsgs_to (user_id, folder_id);

INSERT INTO phpbb_privmsgs_to (msg_id, user_id, author_id, pm_deleted, pm_new, pm_unread, pm_replied, pm_marked, pm_forwarded, folder_id) VALUES (7, 59, 64, 0, 0, 0, 1, 0, 0, 0);
INSERT INTO phpbb_privmsgs_to (msg_id, user_id, author_id, pm_deleted, pm_new, pm_unread, pm_replied, pm_marked, pm_forwarded, folder_id) VALUES (7, 64, 64, 0, 0, 0, 0, 0, 0, -1);
INSERT INTO phpbb_privmsgs_to (msg_id, user_id, author_id, pm_deleted, pm_new, pm_unread, pm_replied, pm_marked, pm_forwarded, folder_id) VALUES (8, 64, 59, 0, 0, 0, 1, 0, 0, 0);
INSERT INTO phpbb_privmsgs_to (msg_id, user_id, author_id, pm_deleted, pm_new, pm_unread, pm_replied, pm_marked, pm_forwarded, folder_id) VALUES (8, 59, 59, 0, 0, 0, 0, 0, 0, -1);
INSERT INTO phpbb_privmsgs_to (msg_id, user_id, author_id, pm_deleted, pm_new, pm_unread, pm_replied, pm_marked, pm_forwarded, folder_id) VALUES (9, 59, 64, 0, 0, 0, 1, 0, 0, 0);
INSERT INTO phpbb_privmsgs_to (msg_id, user_id, author_id, pm_deleted, pm_new, pm_unread, pm_replied, pm_marked, pm_forwarded, folder_id) VALUES (9, 64, 64, 0, 0, 0, 0, 0, 0, -1);
INSERT INTO phpbb_privmsgs_to (msg_id, user_id, author_id, pm_deleted, pm_new, pm_unread, pm_replied, pm_marked, pm_forwarded, folder_id) VALUES (10, 64, 59, 0, 0, 0, 1, 0, 0, 0);
INSERT INTO phpbb_privmsgs_to (msg_id, user_id, author_id, pm_deleted, pm_new, pm_unread, pm_replied, pm_marked, pm_forwarded, folder_id) VALUES (10, 59, 59, 0, 0, 0, 0, 0, 0, -1);
INSERT INTO phpbb_privmsgs_to (msg_id, user_id, author_id, pm_deleted, pm_new, pm_unread, pm_replied, pm_marked, pm_forwarded, folder_id) VALUES (11, 59, 64, 0, 0, 0, 1, 0, 0, 0);
INSERT INTO phpbb_privmsgs_to (msg_id, user_id, author_id, pm_deleted, pm_new, pm_unread, pm_replied, pm_marked, pm_forwarded, folder_id) VALUES (11, 64, 64, 0, 0, 0, 0, 0, 0, -1);
INSERT INTO phpbb_privmsgs_to (msg_id, user_id, author_id, pm_deleted, pm_new, pm_unread, pm_replied, pm_marked, pm_forwarded, folder_id) VALUES (12, 64, 59, 0, 0, 0, 1, 0, 0, 0);
INSERT INTO phpbb_privmsgs_to (msg_id, user_id, author_id, pm_deleted, pm_new, pm_unread, pm_replied, pm_marked, pm_forwarded, folder_id) VALUES (12, 59, 59, 0, 0, 0, 0, 0, 0, -1);
INSERT INTO phpbb_privmsgs_to (msg_id, user_id, author_id, pm_deleted, pm_new, pm_unread, pm_replied, pm_marked, pm_forwarded, folder_id) VALUES (13, 59, 64, 0, 0, 0, 1, 0, 0, 0);
INSERT INTO phpbb_privmsgs_to (msg_id, user_id, author_id, pm_deleted, pm_new, pm_unread, pm_replied, pm_marked, pm_forwarded, folder_id) VALUES (13, 64, 64, 0, 0, 0, 0, 0, 0, -1);
INSERT INTO phpbb_privmsgs_to (msg_id, user_id, author_id, pm_deleted, pm_new, pm_unread, pm_replied, pm_marked, pm_forwarded, folder_id) VALUES (14, 64, 59, 0, 0, 0, 1, 0, 0, 0);
INSERT INTO phpbb_privmsgs_to (msg_id, user_id, author_id, pm_deleted, pm_new, pm_unread, pm_replied, pm_marked, pm_forwarded, folder_id) VALUES (14, 59, 59, 0, 0, 0, 0, 0, 0, -1);
INSERT INTO phpbb_privmsgs_to (msg_id, user_id, author_id, pm_deleted, pm_new, pm_unread, pm_replied, pm_marked, pm_forwarded, folder_id) VALUES (17, 59, 64, 0, 0, 0, 0, 0, 0, 0);
INSERT INTO phpbb_privmsgs_to (msg_id, user_id, author_id, pm_deleted, pm_new, pm_unread, pm_replied, pm_marked, pm_forwarded, folder_id) VALUES (17, 64, 64, 0, 0, 0, 0, 0, 0, -1);
