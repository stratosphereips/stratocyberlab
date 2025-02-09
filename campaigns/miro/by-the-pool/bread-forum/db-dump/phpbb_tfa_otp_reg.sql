create table phpbb_tfa_otp_reg
(
    registration_id INTEGER
        primary key autoincrement,
    user_id         INTEGER UNSIGNED default '0' not null,
    secret          VARCHAR(255)     default ''  not null,
    last_used       INTEGER UNSIGNED default '0' not null,
    registered      INTEGER UNSIGNED default '0' not null
);

create index phpbb_tfa_otp_reg_user_id
    on phpbb_tfa_otp_reg (user_id);

INSERT INTO phpbb_tfa_otp_reg (registration_id, user_id, secret, last_used, registered) VALUES (2, 59, 'I6ZZ27OZBQP6DK4R', 1736090602, 1736090508);
