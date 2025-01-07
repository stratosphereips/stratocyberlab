create table phpbb_icons
(
    icons_id           INTEGER
        primary key autoincrement,
    icons_url          VARCHAR(255)     default ''  not null,
    icons_width        TINYINT(4)       default '0' not null,
    icons_height       TINYINT(4)       default '0' not null,
    icons_alt          VARCHAR(255)     default ''  not null,
    icons_order        INTEGER UNSIGNED default '0' not null,
    display_on_posting INTEGER UNSIGNED default '1' not null
);

create index phpbb_icons_display_on_posting
    on phpbb_icons (display_on_posting);

INSERT INTO phpbb_icons (icons_id, icons_url, icons_width, icons_height, icons_alt, icons_order, display_on_posting) VALUES (1, 'misc/fire.gif', 16, 16, '', 1, 1);
INSERT INTO phpbb_icons (icons_id, icons_url, icons_width, icons_height, icons_alt, icons_order, display_on_posting) VALUES (2, 'smile/redface.gif', 16, 16, '', 9, 1);
INSERT INTO phpbb_icons (icons_id, icons_url, icons_width, icons_height, icons_alt, icons_order, display_on_posting) VALUES (3, 'smile/mrgreen.gif', 16, 16, '', 10, 1);
INSERT INTO phpbb_icons (icons_id, icons_url, icons_width, icons_height, icons_alt, icons_order, display_on_posting) VALUES (4, 'misc/heart.gif', 16, 16, '', 4, 1);
INSERT INTO phpbb_icons (icons_id, icons_url, icons_width, icons_height, icons_alt, icons_order, display_on_posting) VALUES (5, 'misc/star.gif', 16, 16, '', 2, 1);
INSERT INTO phpbb_icons (icons_id, icons_url, icons_width, icons_height, icons_alt, icons_order, display_on_posting) VALUES (6, 'misc/radioactive.gif', 16, 16, '', 3, 1);
INSERT INTO phpbb_icons (icons_id, icons_url, icons_width, icons_height, icons_alt, icons_order, display_on_posting) VALUES (7, 'misc/thinking.gif', 16, 16, '', 5, 1);
INSERT INTO phpbb_icons (icons_id, icons_url, icons_width, icons_height, icons_alt, icons_order, display_on_posting) VALUES (8, 'smile/info.gif', 16, 16, '', 8, 1);
INSERT INTO phpbb_icons (icons_id, icons_url, icons_width, icons_height, icons_alt, icons_order, display_on_posting) VALUES (9, 'smile/question.gif', 16, 16, '', 6, 1);
INSERT INTO phpbb_icons (icons_id, icons_url, icons_width, icons_height, icons_alt, icons_order, display_on_posting) VALUES (10, 'smile/alert.gif', 16, 16, '', 7, 1);
