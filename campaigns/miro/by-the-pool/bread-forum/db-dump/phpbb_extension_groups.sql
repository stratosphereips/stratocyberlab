create table phpbb_extension_groups
(
    group_id       INTEGER
        primary key autoincrement,
    group_name     VARCHAR(255)     default ''  not null,
    cat_id         TINYINT(2)       default '0' not null,
    allow_group    INTEGER UNSIGNED default '0' not null,
    download_mode  INTEGER UNSIGNED default '1' not null,
    upload_icon    VARCHAR(255)     default ''  not null,
    max_filesize   INTEGER UNSIGNED default '0' not null,
    allowed_forums TEXT(65535)      default ''  not null,
    allow_in_pm    INTEGER UNSIGNED default '0' not null
);

INSERT INTO phpbb_extension_groups (group_id, group_name, cat_id, allow_group, download_mode, upload_icon, max_filesize, allowed_forums, allow_in_pm) VALUES (1, 'IMAGES', 1, 1, 1, '', 0, '', 1);
INSERT INTO phpbb_extension_groups (group_id, group_name, cat_id, allow_group, download_mode, upload_icon, max_filesize, allowed_forums, allow_in_pm) VALUES (2, 'ARCHIVES', 0, 1, 1, '', 0, '', 0);
INSERT INTO phpbb_extension_groups (group_id, group_name, cat_id, allow_group, download_mode, upload_icon, max_filesize, allowed_forums, allow_in_pm) VALUES (3, 'PLAIN_TEXT', 0, 0, 1, '', 0, '', 0);
INSERT INTO phpbb_extension_groups (group_id, group_name, cat_id, allow_group, download_mode, upload_icon, max_filesize, allowed_forums, allow_in_pm) VALUES (4, 'DOCUMENTS', 0, 0, 1, '', 0, '', 0);
INSERT INTO phpbb_extension_groups (group_id, group_name, cat_id, allow_group, download_mode, upload_icon, max_filesize, allowed_forums, allow_in_pm) VALUES (5, 'DOWNLOADABLE_FILES', 0, 0, 1, '', 0, '', 1);
