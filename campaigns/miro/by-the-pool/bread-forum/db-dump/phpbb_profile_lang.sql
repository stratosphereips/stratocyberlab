create table phpbb_profile_lang
(
    field_id           INTEGER UNSIGNED default '0' not null,
    lang_id            INTEGER UNSIGNED default '0' not null,
    lang_name          VARCHAR(255)     default ''  not null,
    lang_explain       TEXT(65535)      default ''  not null,
    lang_default_value VARCHAR(255)     default ''  not null,
    primary key (field_id, lang_id)
);

INSERT INTO phpbb_profile_lang (field_id, lang_id, lang_name, lang_explain, lang_default_value) VALUES (1, 1, 'LOCATION', '', '');
INSERT INTO phpbb_profile_lang (field_id, lang_id, lang_name, lang_explain, lang_default_value) VALUES (2, 1, 'WEBSITE', '', '');
INSERT INTO phpbb_profile_lang (field_id, lang_id, lang_name, lang_explain, lang_default_value) VALUES (3, 1, 'INTERESTS', '', '');
INSERT INTO phpbb_profile_lang (field_id, lang_id, lang_name, lang_explain, lang_default_value) VALUES (4, 1, 'OCCUPATION', '', '');
INSERT INTO phpbb_profile_lang (field_id, lang_id, lang_name, lang_explain, lang_default_value) VALUES (5, 1, 'ICQ', '', '');
INSERT INTO phpbb_profile_lang (field_id, lang_id, lang_name, lang_explain, lang_default_value) VALUES (6, 1, 'YAHOO', '', '');
INSERT INTO phpbb_profile_lang (field_id, lang_id, lang_name, lang_explain, lang_default_value) VALUES (7, 1, 'FACEBOOK', '', '');
INSERT INTO phpbb_profile_lang (field_id, lang_id, lang_name, lang_explain, lang_default_value) VALUES (8, 1, 'TWITTER', '', '');
INSERT INTO phpbb_profile_lang (field_id, lang_id, lang_name, lang_explain, lang_default_value) VALUES (9, 1, 'SKYPE', '', '');
INSERT INTO phpbb_profile_lang (field_id, lang_id, lang_name, lang_explain, lang_default_value) VALUES (10, 1, 'YOUTUBE', '', '');
