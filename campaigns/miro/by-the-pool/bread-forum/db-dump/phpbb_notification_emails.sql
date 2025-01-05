create table phpbb_notification_emails
(
    notification_type_id INTEGER UNSIGNED default '0' not null,
    item_id              INTEGER UNSIGNED default '0' not null,
    item_parent_id       INTEGER UNSIGNED default '0' not null,
    user_id              INTEGER UNSIGNED default '0' not null,
    primary key (notification_type_id, item_id, item_parent_id, user_id)
);

