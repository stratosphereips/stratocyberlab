create table phpbb_user_notifications
(
    item_type VARCHAR(165)     default ''  not null,
    item_id   INTEGER UNSIGNED default '0' not null,
    user_id   INTEGER UNSIGNED default '0' not null,
    method    VARCHAR(165)     default ''  not null,
    notify    INTEGER UNSIGNED default '1' not null
);

create unique index itm_usr_mthd
    on phpbb_user_notifications (item_type, item_id, user_id, method);

create index user_notifications_uid_itm_id
    on phpbb_user_notifications (user_id, item_id);

create index user_notifications_user_id
    on phpbb_user_notifications (user_id);

create index user_notifications_usr_itm_tpe
    on phpbb_user_notifications (user_id, item_type, item_id);

INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 2, 'notification.method.board', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 2, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 2, 'notification.method.board', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 2, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.forum', 0, 2, 'notification.method.board', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.forum', 0, 2, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 3, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 3, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 4, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 4, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 5, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 5, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 6, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 6, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 7, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 7, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 8, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 8, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 9, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 9, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 10, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 10, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 11, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 11, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 12, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 12, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 13, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 13, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 14, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 14, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 15, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 15, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 16, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 16, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 17, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 17, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 18, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 18, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 19, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 19, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 20, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 20, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 21, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 21, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 22, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 22, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 23, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 23, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 24, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 24, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 25, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 25, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 26, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 26, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 27, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 27, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 28, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 28, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 29, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 29, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 30, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 30, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 31, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 31, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 32, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 32, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 33, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 33, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 34, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 34, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 35, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 35, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 36, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 36, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 37, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 37, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 38, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 38, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 39, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 39, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 40, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 40, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 41, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 41, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 42, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 42, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 43, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 43, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 44, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 44, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 45, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 45, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 46, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 46, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 47, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 47, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 48, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 48, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 49, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 49, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 50, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 50, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 51, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 51, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 52, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 52, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 53, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 53, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 54, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 54, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 55, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 55, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 56, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 56, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 57, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 57, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 58, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 58, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 59, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 59, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 60, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 60, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 61, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 61, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 62, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 62, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 63, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 63, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.post', 0, 64, 'notification.method.email', 1);
INSERT INTO phpbb_user_notifications (item_type, item_id, user_id, method, notify) VALUES ('notification.type.topic', 0, 64, 'notification.method.email', 1);
