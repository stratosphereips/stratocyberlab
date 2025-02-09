create table phpbb_extensions
(
    extension_id INTEGER
        primary key autoincrement,
    group_id     INTEGER UNSIGNED default '0' not null,
    extension    VARCHAR(100)     default ''  not null
);

INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (1, 1, 'gif');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (2, 1, 'png');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (3, 1, 'jpeg');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (4, 1, 'jpg');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (5, 1, 'tif');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (6, 1, 'tiff');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (7, 1, 'tga');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (8, 2, 'gtar');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (9, 2, 'gz');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (10, 2, 'tar');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (11, 2, 'zip');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (12, 2, 'rar');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (13, 2, 'ace');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (14, 2, 'torrent');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (15, 2, 'tgz');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (16, 2, 'bz2');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (17, 2, '7z');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (18, 3, 'txt');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (19, 3, 'c');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (20, 3, 'h');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (21, 3, 'cpp');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (22, 3, 'hpp');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (23, 3, 'diz');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (24, 3, 'csv');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (25, 3, 'ini');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (26, 3, 'log');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (27, 3, 'js');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (28, 3, 'xml');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (29, 4, 'xls');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (30, 4, 'xlsx');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (31, 4, 'xlsm');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (32, 4, 'xlsb');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (33, 4, 'doc');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (34, 4, 'docx');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (35, 4, 'docm');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (36, 4, 'dot');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (37, 4, 'dotx');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (38, 4, 'dotm');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (39, 4, 'pdf');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (40, 4, 'ai');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (41, 4, 'ps');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (42, 4, 'ppt');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (43, 4, 'pptx');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (44, 4, 'pptm');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (45, 4, 'odg');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (46, 4, 'odp');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (47, 4, 'ods');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (48, 4, 'odt');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (49, 4, 'rtf');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (50, 5, 'mp3');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (51, 5, 'mpeg');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (52, 5, 'mpg');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (53, 5, 'ogg');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (54, 5, 'ogm');
INSERT INTO phpbb_extensions (extension_id, group_id, extension) VALUES (55, 2, '*');
