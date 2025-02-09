create table phpbb_words
(
    word_id     INTEGER
        primary key autoincrement,
    word        VARCHAR(255) default '' not null,
    replacement VARCHAR(255) default '' not null
);

