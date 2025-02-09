create table phpbb_bbcodes
(
    bbcode_id           INTEGER UNSIGNED     default '0' not null
        primary key,
    bbcode_tag          VARCHAR(16)          default ''  not null,
    bbcode_helpline     TEXT(65535)          default ''  not null,
    display_on_posting  INTEGER UNSIGNED     default '0' not null,
    bbcode_match        TEXT(65535)          default ''  not null,
    bbcode_tpl          MEDIUMTEXT(16777215) default ''  not null,
    first_pass_match    MEDIUMTEXT(16777215) default ''  not null,
    first_pass_replace  MEDIUMTEXT(16777215) default ''  not null,
    second_pass_match   MEDIUMTEXT(16777215) default ''  not null,
    second_pass_replace MEDIUMTEXT(16777215) default ''  not null
);

create index phpbb_bbcodes_display_on_post
    on phpbb_bbcodes (display_on_posting);

