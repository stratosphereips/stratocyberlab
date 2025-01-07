create table phpbb_styles
(
    style_id          INTEGER
        primary key autoincrement,
    style_name        VARCHAR(255)     default ''     not null,
    style_copyright   VARCHAR(255)     default ''     not null,
    style_active      INTEGER UNSIGNED default '1'    not null,
    style_path        VARCHAR(100)     default ''     not null,
    bbcode_bitfield   VARCHAR(255)     default 'kNg=' not null,
    style_parent_id   INTEGER UNSIGNED default '0'    not null,
    style_parent_tree TEXT(65535)      default ''     not null
);

create unique index phpbb_styles_style_name
    on phpbb_styles (style_name);

INSERT INTO phpbb_styles (style_id, style_name, style_copyright, style_active, style_path, bbcode_bitfield, style_parent_id, style_parent_tree) VALUES (1, 'prosilver', '&copy; phpBB Limited', 1, 'prosilver', '//g=', 0, '');
