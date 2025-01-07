create table phpbb_zebra
(
    user_id  INTEGER UNSIGNED default '0' not null,
    zebra_id INTEGER UNSIGNED default '0' not null,
    friend   INTEGER UNSIGNED default '0' not null,
    foe      INTEGER UNSIGNED default '0' not null,
    primary key (user_id, zebra_id)
);

