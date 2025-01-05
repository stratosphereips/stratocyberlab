create table phpbb_lang
(
    lang_id           INTEGER
        primary key autoincrement,
    lang_iso          VARCHAR(30)  default '' not null,
    lang_dir          VARCHAR(30)  default '' not null,
    lang_english_name VARCHAR(100) default '' not null,
    lang_local_name   VARCHAR(255) default '' not null,
    lang_author       VARCHAR(255) default '' not null
);

create index phpbb_lang_lang_iso
    on phpbb_lang (lang_iso);

INSERT INTO phpbb_lang (lang_id, lang_iso, lang_dir, lang_english_name, lang_local_name, lang_author) VALUES (1, 'en', 'en', 'British English', 'British English', 'phpBB Limited');
