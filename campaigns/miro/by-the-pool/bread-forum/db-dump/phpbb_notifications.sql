create table phpbb_notifications
(
    notification_id      INTEGER
        primary key autoincrement,
    notification_type_id INTEGER UNSIGNED default '0' not null,
    item_id              INTEGER UNSIGNED default '0' not null,
    item_parent_id       INTEGER UNSIGNED default '0' not null,
    user_id              INTEGER UNSIGNED default '0' not null,
    notification_read    INTEGER UNSIGNED default '0' not null,
    notification_time    INTEGER UNSIGNED default '1' not null,
    notification_data    TEXT(65535)      default ''  not null
);

create index phpbb_notifications_item_ident
    on phpbb_notifications (notification_type_id, item_id);

create index phpbb_notifications_user
    on phpbb_notifications (user_id, notification_read);

INSERT INTO phpbb_notifications (notification_id, notification_type_id, item_id, item_parent_id, user_id, notification_read, notification_time, notification_data) VALUES (9, 3, 9, 3, 62, 0, 1736080282, 'a:6:{s:9:"poster_id";i:63;s:11:"topic_title";s:47:"Seeking Assistance with a Disruptive Individual";s:12:"post_subject";s:51:"Re: Seeking Assistance with a Disruptive Individual";s:13:"post_username";s:0:"";s:8:"forum_id";i:14;s:10:"forum_name";s:8:"Requests";}');
INSERT INTO phpbb_notifications (notification_id, notification_type_id, item_id, item_parent_id, user_id, notification_read, notification_time, notification_data) VALUES (10, 10, 7, 0, 59, 1, 1736080602, 'a:2:{s:12:"from_user_id";i:64;s:15:"message_subject";s:51:"Re: Seeking Assistance with a Disruptive Individual";}');
INSERT INTO phpbb_notifications (notification_id, notification_type_id, item_id, item_parent_id, user_id, notification_read, notification_time, notification_data) VALUES (11, 10, 8, 0, 64, 1, 1736080947, 'a:2:{s:12:"from_user_id";i:59;s:15:"message_subject";s:51:"Re: Seeking Assistance with a Disruptive Individual";}');
INSERT INTO phpbb_notifications (notification_id, notification_type_id, item_id, item_parent_id, user_id, notification_read, notification_time, notification_data) VALUES (12, 10, 9, 0, 59, 1, 1736081169, 'a:2:{s:12:"from_user_id";i:64;s:15:"message_subject";s:51:"Re: Seeking Assistance with a Disruptive Individual";}');
INSERT INTO phpbb_notifications (notification_id, notification_type_id, item_id, item_parent_id, user_id, notification_read, notification_time, notification_data) VALUES (13, 10, 10, 0, 64, 1, 1736081226, 'a:2:{s:12:"from_user_id";i:59;s:15:"message_subject";s:51:"Re: Seeking Assistance with a Disruptive Individual";}');
INSERT INTO phpbb_notifications (notification_id, notification_type_id, item_id, item_parent_id, user_id, notification_read, notification_time, notification_data) VALUES (14, 10, 11, 0, 59, 1, 1736082429, 'a:2:{s:12:"from_user_id";i:64;s:15:"message_subject";s:51:"Re: Seeking Assistance with a Disruptive Individual";}');
INSERT INTO phpbb_notifications (notification_id, notification_type_id, item_id, item_parent_id, user_id, notification_read, notification_time, notification_data) VALUES (15, 10, 12, 0, 64, 1, 1736082500, 'a:2:{s:12:"from_user_id";i:59;s:15:"message_subject";s:51:"Re: Seeking Assistance with a Disruptive Individual";}');
INSERT INTO phpbb_notifications (notification_id, notification_type_id, item_id, item_parent_id, user_id, notification_read, notification_time, notification_data) VALUES (16, 10, 13, 0, 59, 1, 1736082666, 'a:2:{s:12:"from_user_id";i:64;s:15:"message_subject";s:51:"Re: Seeking Assistance with a Disruptive Individual";}');
INSERT INTO phpbb_notifications (notification_id, notification_type_id, item_id, item_parent_id, user_id, notification_read, notification_time, notification_data) VALUES (17, 10, 14, 0, 64, 1, 1736089385, 'a:2:{s:12:"from_user_id";i:59;s:15:"message_subject";s:51:"Re: Seeking Assistance with a Disruptive Individual";}');
INSERT INTO phpbb_notifications (notification_id, notification_type_id, item_id, item_parent_id, user_id, notification_read, notification_time, notification_data) VALUES (20, 10, 17, 0, 59, 1, 1736090102, 'a:2:{s:12:"from_user_id";i:64;s:15:"message_subject";s:51:"Re: Seeking Assistance with a Disruptive Individual";}');
