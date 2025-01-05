create table phpbb_search_results
(
    search_key      VARCHAR(32)          default ''  not null
        primary key,
    search_time     INTEGER UNSIGNED     default '0' not null,
    search_keywords MEDIUMTEXT(16777215) default ''  not null,
    search_authors  MEDIUMTEXT(16777215) default ''  not null
);

