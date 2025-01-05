create table phpbb_sitelist
(
    site_id       INTEGER
        primary key autoincrement,
    site_ip       VARCHAR(40)      default ''  not null,
    site_hostname VARCHAR(255)     default ''  not null,
    ip_exclude    INTEGER UNSIGNED default '0' not null
);

