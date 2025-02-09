create table phpbb_reports_reasons
(
    reason_id          INTEGER
        primary key autoincrement,
    reason_title       VARCHAR(255)         default ''  not null,
    reason_description MEDIUMTEXT(16777215) default ''  not null,
    reason_order       INTEGER UNSIGNED     default '0' not null
);

INSERT INTO phpbb_reports_reasons (reason_id, reason_title, reason_description, reason_order) VALUES (1, 'warez', 'The post contains links to illegal or pirated software.', 1);
INSERT INTO phpbb_reports_reasons (reason_id, reason_title, reason_description, reason_order) VALUES (2, 'spam', 'The reported post has the only purpose to advertise for a website or another product.', 2);
INSERT INTO phpbb_reports_reasons (reason_id, reason_title, reason_description, reason_order) VALUES (3, 'off_topic', 'The reported post is off topic.', 3);
INSERT INTO phpbb_reports_reasons (reason_id, reason_title, reason_description, reason_order) VALUES (4, 'other', 'The reported post does not fit into any other category, please use the further information field.', 4);
