create table phpbb_moderator_cache
(
    forum_id         INTEGER UNSIGNED default '0' not null,
    user_id          INTEGER UNSIGNED default '0' not null,
    username         VARCHAR(255)     default ''  not null,
    group_id         INTEGER UNSIGNED default '0' not null,
    group_name       VARCHAR(255)     default ''  not null,
    display_on_index INTEGER UNSIGNED default '1' not null
);

create index phpbb_moderator_cache_disp_idx
    on phpbb_moderator_cache (display_on_index);

create index phpbb_moderator_cache_forum_id
    on phpbb_moderator_cache (forum_id);

