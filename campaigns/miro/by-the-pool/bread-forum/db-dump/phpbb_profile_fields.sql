create table phpbb_profile_fields
(
    field_id            INTEGER
        primary key autoincrement,
    field_name          VARCHAR(255)     default ''  not null,
    field_type          VARCHAR(100)     default ''  not null,
    field_ident         VARCHAR(20)      default ''  not null,
    field_length        VARCHAR(20)      default ''  not null,
    field_minlen        VARCHAR(255)     default ''  not null,
    field_maxlen        VARCHAR(255)     default ''  not null,
    field_novalue       VARCHAR(255)     default ''  not null,
    field_default_value VARCHAR(255)     default ''  not null,
    field_validation    VARCHAR(128)     default ''  not null,
    field_required      INTEGER UNSIGNED default '0' not null,
    field_show_on_reg   INTEGER UNSIGNED default '0' not null,
    field_hide          INTEGER UNSIGNED default '0' not null,
    field_no_view       INTEGER UNSIGNED default '0' not null,
    field_active        INTEGER UNSIGNED default '0' not null,
    field_order         INTEGER UNSIGNED default '0' not null,
    field_show_profile  INTEGER UNSIGNED default '0' not null,
    field_show_on_vt    INTEGER UNSIGNED default '0' not null,
    field_show_novalue  INTEGER UNSIGNED default '0' not null,
    field_show_on_pm    INTEGER UNSIGNED default '0' not null,
    field_show_on_ml    INTEGER UNSIGNED default '0' not null,
    field_is_contact    INTEGER UNSIGNED default '0' not null,
    field_contact_desc  VARCHAR(255)     default ''  not null,
    field_contact_url   VARCHAR(255)     default ''  not null
);

create index phpbb_profile_fields_fld_ordr
    on phpbb_profile_fields (field_order);

create index phpbb_profile_fields_fld_type
    on phpbb_profile_fields (field_type);

INSERT INTO phpbb_profile_fields (field_id, field_name, field_type, field_ident, field_length, field_minlen, field_maxlen, field_novalue, field_default_value, field_validation, field_required, field_show_on_reg, field_hide, field_no_view, field_active, field_order, field_show_profile, field_show_on_vt, field_show_novalue, field_show_on_pm, field_show_on_ml, field_is_contact, field_contact_desc, field_contact_url) VALUES (1, 'phpbb_location', 'profilefields.type.string', 'phpbb_location', '20', '2', '100', '', '', '.*', 0, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, '', '');
INSERT INTO phpbb_profile_fields (field_id, field_name, field_type, field_ident, field_length, field_minlen, field_maxlen, field_novalue, field_default_value, field_validation, field_required, field_show_on_reg, field_hide, field_no_view, field_active, field_order, field_show_profile, field_show_on_vt, field_show_novalue, field_show_on_pm, field_show_on_ml, field_is_contact, field_contact_desc, field_contact_url) VALUES (2, 'phpbb_website', 'profilefields.type.url', 'phpbb_website', '40', '12', '255', '', '', '', 0, 0, 0, 0, 1, 2, 1, 1, 0, 1, 1, 1, 'VISIT_WEBSITE', '%s');
INSERT INTO phpbb_profile_fields (field_id, field_name, field_type, field_ident, field_length, field_minlen, field_maxlen, field_novalue, field_default_value, field_validation, field_required, field_show_on_reg, field_hide, field_no_view, field_active, field_order, field_show_profile, field_show_on_vt, field_show_novalue, field_show_on_pm, field_show_on_ml, field_is_contact, field_contact_desc, field_contact_url) VALUES (3, 'phpbb_interests', 'profilefields.type.text', 'phpbb_interests', '3|30', '2', '500', '', '', '.*', 0, 0, 0, 0, 0, 3, 1, 0, 0, 0, 0, 0, '', '');
INSERT INTO phpbb_profile_fields (field_id, field_name, field_type, field_ident, field_length, field_minlen, field_maxlen, field_novalue, field_default_value, field_validation, field_required, field_show_on_reg, field_hide, field_no_view, field_active, field_order, field_show_profile, field_show_on_vt, field_show_novalue, field_show_on_pm, field_show_on_ml, field_is_contact, field_contact_desc, field_contact_url) VALUES (4, 'phpbb_occupation', 'profilefields.type.text', 'phpbb_occupation', '3|30', '2', '500', '', '', '.*', 0, 0, 0, 0, 0, 4, 1, 0, 0, 0, 0, 0, '', '');
INSERT INTO phpbb_profile_fields (field_id, field_name, field_type, field_ident, field_length, field_minlen, field_maxlen, field_novalue, field_default_value, field_validation, field_required, field_show_on_reg, field_hide, field_no_view, field_active, field_order, field_show_profile, field_show_on_vt, field_show_novalue, field_show_on_pm, field_show_on_ml, field_is_contact, field_contact_desc, field_contact_url) VALUES (5, 'phpbb_icq', 'profilefields.type.string', 'phpbb_icq', '20', '3', '15', '', '', '[0-9]+', 0, 0, 0, 0, 0, 6, 1, 1, 0, 1, 1, 1, 'SEND_ICQ_MESSAGE', 'https://www.icq.com/people/%s/');
INSERT INTO phpbb_profile_fields (field_id, field_name, field_type, field_ident, field_length, field_minlen, field_maxlen, field_novalue, field_default_value, field_validation, field_required, field_show_on_reg, field_hide, field_no_view, field_active, field_order, field_show_profile, field_show_on_vt, field_show_novalue, field_show_on_pm, field_show_on_ml, field_is_contact, field_contact_desc, field_contact_url) VALUES (6, 'phpbb_yahoo', 'profilefields.type.string', 'phpbb_yahoo', '40', '5', '255', '', '', '.*', 0, 0, 0, 0, 0, 8, 1, 1, 0, 1, 1, 1, 'SEND_YIM_MESSAGE', 'ymsgr:sendim?%s');
INSERT INTO phpbb_profile_fields (field_id, field_name, field_type, field_ident, field_length, field_minlen, field_maxlen, field_novalue, field_default_value, field_validation, field_required, field_show_on_reg, field_hide, field_no_view, field_active, field_order, field_show_profile, field_show_on_vt, field_show_novalue, field_show_on_pm, field_show_on_ml, field_is_contact, field_contact_desc, field_contact_url) VALUES (7, 'phpbb_facebook', 'profilefields.type.string', 'phpbb_facebook', '20', '5', '50', '', '', '[\w.]+', 0, 0, 0, 0, 1, 9, 1, 1, 0, 1, 1, 1, 'VIEW_FACEBOOK_PROFILE', 'https://facebook.com/%s/');
INSERT INTO phpbb_profile_fields (field_id, field_name, field_type, field_ident, field_length, field_minlen, field_maxlen, field_novalue, field_default_value, field_validation, field_required, field_show_on_reg, field_hide, field_no_view, field_active, field_order, field_show_profile, field_show_on_vt, field_show_novalue, field_show_on_pm, field_show_on_ml, field_is_contact, field_contact_desc, field_contact_url) VALUES (8, 'phpbb_twitter', 'profilefields.type.string', 'phpbb_twitter', '20', '1', '15', '', '', '[\w_]+', 0, 0, 0, 0, 1, 10, 1, 1, 0, 1, 1, 1, 'VIEW_TWITTER_PROFILE', 'https://twitter.com/%s');
INSERT INTO phpbb_profile_fields (field_id, field_name, field_type, field_ident, field_length, field_minlen, field_maxlen, field_novalue, field_default_value, field_validation, field_required, field_show_on_reg, field_hide, field_no_view, field_active, field_order, field_show_profile, field_show_on_vt, field_show_novalue, field_show_on_pm, field_show_on_ml, field_is_contact, field_contact_desc, field_contact_url) VALUES (9, 'phpbb_skype', 'profilefields.type.string', 'phpbb_skype', '20', '6', '32', '', '', '[a-zA-Z][\w\.,\-_]+', 0, 0, 0, 0, 1, 11, 1, 1, 0, 1, 1, 1, 'VIEW_SKYPE_PROFILE', 'skype:%s?userinfo');
INSERT INTO phpbb_profile_fields (field_id, field_name, field_type, field_ident, field_length, field_minlen, field_maxlen, field_novalue, field_default_value, field_validation, field_required, field_show_on_reg, field_hide, field_no_view, field_active, field_order, field_show_profile, field_show_on_vt, field_show_novalue, field_show_on_pm, field_show_on_ml, field_is_contact, field_contact_desc, field_contact_url) VALUES (10, 'phpbb_youtube', 'profilefields.type.string', 'phpbb_youtube', '20', '3', '60', '', '', '(@[a-zA-Z0-9_.-]{3,30}|c/[a-zA-Z][\w\.,\-_]+|(channel|user)/[a-zA-Z][\w\.,\-_]+)', 0, 0, 0, 0, 1, 12, 1, 1, 0, 1, 1, 1, 'VIEW_YOUTUBE_PROFILE', 'https://youtube.com/%s');
