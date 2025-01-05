create table phpbb_notification_types
(
    notification_type_id      INTEGER
        primary key autoincrement,
    notification_type_name    VARCHAR(255)     default ''  not null,
    notification_type_enabled INTEGER UNSIGNED default '1' not null
);

create unique index phpbb_notification_types_type
    on phpbb_notification_types (notification_type_name);

INSERT INTO phpbb_notification_types (notification_type_id, notification_type_name, notification_type_enabled) VALUES (1, 'notification.type.topic', 1);
INSERT INTO phpbb_notification_types (notification_type_id, notification_type_name, notification_type_enabled) VALUES (2, 'notification.type.approve_topic', 1);
INSERT INTO phpbb_notification_types (notification_type_id, notification_type_name, notification_type_enabled) VALUES (3, 'notification.type.quote', 1);
INSERT INTO phpbb_notification_types (notification_type_id, notification_type_name, notification_type_enabled) VALUES (4, 'notification.type.bookmark', 1);
INSERT INTO phpbb_notification_types (notification_type_id, notification_type_name, notification_type_enabled) VALUES (5, 'notification.type.post', 1);
INSERT INTO phpbb_notification_types (notification_type_id, notification_type_name, notification_type_enabled) VALUES (6, 'notification.type.approve_post', 1);
INSERT INTO phpbb_notification_types (notification_type_id, notification_type_name, notification_type_enabled) VALUES (7, 'notification.type.forum', 1);
INSERT INTO phpbb_notification_types (notification_type_id, notification_type_name, notification_type_enabled) VALUES (8, 'notification.type.group_request', 1);
INSERT INTO phpbb_notification_types (notification_type_id, notification_type_name, notification_type_enabled) VALUES (9, 'notification.type.post_in_queue', 1);
INSERT INTO phpbb_notification_types (notification_type_id, notification_type_name, notification_type_enabled) VALUES (10, 'notification.type.pm', 1);
INSERT INTO phpbb_notification_types (notification_type_id, notification_type_name, notification_type_enabled) VALUES (11, 'notification.type.report_post', 1);
INSERT INTO phpbb_notification_types (notification_type_id, notification_type_name, notification_type_enabled) VALUES (12, 'notification.type.topic_in_queue', 1);
