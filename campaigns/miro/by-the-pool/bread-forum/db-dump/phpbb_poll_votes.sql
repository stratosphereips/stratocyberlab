create table phpbb_poll_votes
(
    topic_id       INTEGER UNSIGNED default '0' not null,
    poll_option_id TINYINT(4)       default '0' not null,
    vote_user_id   INTEGER UNSIGNED default '0' not null,
    vote_user_ip   VARCHAR(40)      default ''  not null
);

create index phpbb_poll_votes_topic_id
    on phpbb_poll_votes (topic_id);

create index phpbb_poll_votes_vote_user_id
    on phpbb_poll_votes (vote_user_id);

create index phpbb_poll_votes_vote_user_ip
    on phpbb_poll_votes (vote_user_ip);

