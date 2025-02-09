create table phpbb_ext
(
    ext_name   VARCHAR(255)     default ''  not null,
    ext_active INTEGER UNSIGNED default '0' not null,
    ext_state  TEXT(65535)      default ''  not null
);

create unique index phpbb_ext_ext_name
    on phpbb_ext (ext_name);

INSERT INTO phpbb_ext (ext_name, ext_active, ext_state) VALUES ('phpbb/viglink', 0, 'b:0;');
INSERT INTO phpbb_ext (ext_name, ext_active, ext_state) VALUES ('paul999/tfa', 1, 'b:0;');
