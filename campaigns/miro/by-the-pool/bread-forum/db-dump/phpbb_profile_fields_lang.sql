create table phpbb_profile_fields_lang
(
    field_id   INTEGER UNSIGNED default '0' not null,
    lang_id    INTEGER UNSIGNED default '0' not null,
    option_id  INTEGER UNSIGNED default '0' not null,
    field_type VARCHAR(100)     default ''  not null,
    lang_value VARCHAR(255)     default ''  not null,
    primary key (field_id, lang_id, option_id)
);

