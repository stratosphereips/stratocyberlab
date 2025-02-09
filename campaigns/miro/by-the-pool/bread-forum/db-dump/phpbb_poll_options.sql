create table phpbb_poll_options
(
    poll_option_id    TINYINT(4)       default '0' not null,
    topic_id          INTEGER UNSIGNED default '0' not null,
    poll_option_text  TEXT(65535)      default ''  not null,
    poll_option_total INTEGER UNSIGNED default '0' not null
);

create index phpbb_poll_options_poll_opt_id
    on phpbb_poll_options (poll_option_id);

create index phpbb_poll_options_topic_id
    on phpbb_poll_options (topic_id);

