create table phpbb_teampage
(
    teampage_id       INTEGER
        primary key autoincrement,
    group_id          INTEGER UNSIGNED default '0' not null,
    teampage_name     VARCHAR(255)     default ''  not null,
    teampage_position INTEGER UNSIGNED default '0' not null,
    teampage_parent   INTEGER UNSIGNED default '0' not null
);

INSERT INTO phpbb_teampage (teampage_id, group_id, teampage_name, teampage_position, teampage_parent) VALUES (1, 5, '', 1, 0);
INSERT INTO phpbb_teampage (teampage_id, group_id, teampage_name, teampage_position, teampage_parent) VALUES (2, 4, '', 2, 0);
