create table phpbb_ranks
(
    rank_id      INTEGER
        primary key autoincrement,
    rank_title   VARCHAR(255)     default ''  not null,
    rank_min     INTEGER UNSIGNED default '0' not null,
    rank_special INTEGER UNSIGNED default '0' not null,
    rank_image   VARCHAR(255)     default ''  not null
);

INSERT INTO phpbb_ranks (rank_id, rank_title, rank_min, rank_special, rank_image) VALUES (1, 'Site Admin', 0, 1, '');
