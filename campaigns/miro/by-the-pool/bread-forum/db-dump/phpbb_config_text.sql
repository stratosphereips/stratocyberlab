create table phpbb_config_text
(
    config_name  VARCHAR(255)         default '' not null
        primary key,
    config_value MEDIUMTEXT(16777215) default '' not null
);

INSERT INTO phpbb_config_text (config_name, config_value) VALUES ('contact_admin_info', '');
INSERT INTO phpbb_config_text (config_name, config_value) VALUES ('contact_admin_info_uid', '');
INSERT INTO phpbb_config_text (config_name, config_value) VALUES ('contact_admin_info_bitfield', '');
INSERT INTO phpbb_config_text (config_name, config_value) VALUES ('contact_admin_info_flags', '7');
INSERT INTO phpbb_config_text (config_name, config_value) VALUES ('reparser_resume', 'a:4:{s:28:"text_reparser.user_signature";a:3:{s:9:"range-min";i:1;s:9:"range-max";i:0;s:10:"range-size";i:100;}s:24:"text_reparser.poll_title";a:3:{s:9:"range-min";i:1;s:9:"range-max";i:0;s:10:"range-size";i:100;}s:23:"text_reparser.post_text";a:3:{s:9:"range-min";i:1;s:9:"range-max";i:0;s:10:"range-size";i:100;}s:21:"text_reparser.pm_text";a:3:{s:9:"range-min";i:1;s:9:"range-max";i:0;s:10:"range-size";i:100;}}');
