create table phpbb_user_group
(
    group_id     INTEGER UNSIGNED default '0' not null,
    user_id      INTEGER UNSIGNED default '0' not null,
    group_leader INTEGER UNSIGNED default '0' not null,
    user_pending INTEGER UNSIGNED default '1' not null
);

create index phpbb_user_group_group_id
    on phpbb_user_group (group_id);

create index phpbb_user_group_group_leader
    on phpbb_user_group (group_leader);

create index phpbb_user_group_user_id
    on phpbb_user_group (user_id);

INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (1, 1, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (2, 2, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (4, 2, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (5, 2, 1, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 3, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 4, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 5, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 6, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 7, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 8, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 9, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 10, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 11, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 12, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 13, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 14, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 15, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 16, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 17, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 18, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 19, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 20, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 21, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 22, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 23, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 24, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 25, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 26, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 27, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 28, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 29, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 30, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 31, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 32, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 33, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 34, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 35, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 36, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 37, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 38, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 39, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 40, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 41, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 42, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 43, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 44, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 45, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 46, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 47, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 48, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 49, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 50, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 51, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 52, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 53, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 54, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 55, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 56, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (6, 57, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (2, 58, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (7, 58, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (2, 59, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (7, 59, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (2, 60, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (7, 60, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (2, 61, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (7, 61, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (2, 62, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (7, 62, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (2, 63, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (7, 63, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (4, 63, 1, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (2, 64, 0, 0);
INSERT INTO phpbb_user_group (group_id, user_id, group_leader, user_pending) VALUES (7, 64, 0, 0);
