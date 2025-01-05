create table phpbb_acl_roles
(
    role_id          INTEGER
        primary key autoincrement,
    role_name        VARCHAR(255)     default ''  not null,
    role_description TEXT(65535)      default ''  not null,
    role_type        VARCHAR(10)      default ''  not null,
    role_order       INTEGER UNSIGNED default '0' not null
);

create index phpbb_acl_roles_role_order
    on phpbb_acl_roles (role_order);

create index phpbb_acl_roles_role_type
    on phpbb_acl_roles (role_type);

INSERT INTO phpbb_acl_roles (role_id, role_name, role_description, role_type, role_order) VALUES (1, 'ROLE_ADMIN_STANDARD', 'ROLE_DESCRIPTION_ADMIN_STANDARD', 'a_', 1);
INSERT INTO phpbb_acl_roles (role_id, role_name, role_description, role_type, role_order) VALUES (2, 'ROLE_ADMIN_FORUM', 'ROLE_DESCRIPTION_ADMIN_FORUM', 'a_', 3);
INSERT INTO phpbb_acl_roles (role_id, role_name, role_description, role_type, role_order) VALUES (3, 'ROLE_ADMIN_USERGROUP', 'ROLE_DESCRIPTION_ADMIN_USERGROUP', 'a_', 4);
INSERT INTO phpbb_acl_roles (role_id, role_name, role_description, role_type, role_order) VALUES (4, 'ROLE_ADMIN_FULL', 'ROLE_DESCRIPTION_ADMIN_FULL', 'a_', 2);
INSERT INTO phpbb_acl_roles (role_id, role_name, role_description, role_type, role_order) VALUES (5, 'ROLE_USER_FULL', 'ROLE_DESCRIPTION_USER_FULL', 'u_', 3);
INSERT INTO phpbb_acl_roles (role_id, role_name, role_description, role_type, role_order) VALUES (6, 'ROLE_USER_STANDARD', 'ROLE_DESCRIPTION_USER_STANDARD', 'u_', 1);
INSERT INTO phpbb_acl_roles (role_id, role_name, role_description, role_type, role_order) VALUES (7, 'ROLE_USER_LIMITED', 'ROLE_DESCRIPTION_USER_LIMITED', 'u_', 2);
INSERT INTO phpbb_acl_roles (role_id, role_name, role_description, role_type, role_order) VALUES (8, 'ROLE_USER_NOPM', 'ROLE_DESCRIPTION_USER_NOPM', 'u_', 4);
INSERT INTO phpbb_acl_roles (role_id, role_name, role_description, role_type, role_order) VALUES (9, 'ROLE_USER_NOAVATAR', 'ROLE_DESCRIPTION_USER_NOAVATAR', 'u_', 5);
INSERT INTO phpbb_acl_roles (role_id, role_name, role_description, role_type, role_order) VALUES (10, 'ROLE_MOD_FULL', 'ROLE_DESCRIPTION_MOD_FULL', 'm_', 3);
INSERT INTO phpbb_acl_roles (role_id, role_name, role_description, role_type, role_order) VALUES (11, 'ROLE_MOD_STANDARD', 'ROLE_DESCRIPTION_MOD_STANDARD', 'm_', 1);
INSERT INTO phpbb_acl_roles (role_id, role_name, role_description, role_type, role_order) VALUES (12, 'ROLE_MOD_SIMPLE', 'ROLE_DESCRIPTION_MOD_SIMPLE', 'm_', 2);
INSERT INTO phpbb_acl_roles (role_id, role_name, role_description, role_type, role_order) VALUES (13, 'ROLE_MOD_QUEUE', 'ROLE_DESCRIPTION_MOD_QUEUE', 'm_', 4);
INSERT INTO phpbb_acl_roles (role_id, role_name, role_description, role_type, role_order) VALUES (14, 'ROLE_FORUM_FULL', 'ROLE_DESCRIPTION_FORUM_FULL', 'f_', 7);
INSERT INTO phpbb_acl_roles (role_id, role_name, role_description, role_type, role_order) VALUES (15, 'ROLE_FORUM_STANDARD', 'ROLE_DESCRIPTION_FORUM_STANDARD', 'f_', 5);
INSERT INTO phpbb_acl_roles (role_id, role_name, role_description, role_type, role_order) VALUES (16, 'ROLE_FORUM_NOACCESS', 'ROLE_DESCRIPTION_FORUM_NOACCESS', 'f_', 1);
INSERT INTO phpbb_acl_roles (role_id, role_name, role_description, role_type, role_order) VALUES (17, 'ROLE_FORUM_READONLY', 'ROLE_DESCRIPTION_FORUM_READONLY', 'f_', 2);
INSERT INTO phpbb_acl_roles (role_id, role_name, role_description, role_type, role_order) VALUES (18, 'ROLE_FORUM_LIMITED', 'ROLE_DESCRIPTION_FORUM_LIMITED', 'f_', 3);
INSERT INTO phpbb_acl_roles (role_id, role_name, role_description, role_type, role_order) VALUES (19, 'ROLE_FORUM_BOT', 'ROLE_DESCRIPTION_FORUM_BOT', 'f_', 9);
INSERT INTO phpbb_acl_roles (role_id, role_name, role_description, role_type, role_order) VALUES (20, 'ROLE_FORUM_ONQUEUE', 'ROLE_DESCRIPTION_FORUM_ONQUEUE', 'f_', 8);
INSERT INTO phpbb_acl_roles (role_id, role_name, role_description, role_type, role_order) VALUES (21, 'ROLE_FORUM_POLLS', 'ROLE_DESCRIPTION_FORUM_POLLS', 'f_', 6);
INSERT INTO phpbb_acl_roles (role_id, role_name, role_description, role_type, role_order) VALUES (22, 'ROLE_FORUM_LIMITED_POLLS', 'ROLE_DESCRIPTION_FORUM_LIMITED_POLLS', 'f_', 4);
INSERT INTO phpbb_acl_roles (role_id, role_name, role_description, role_type, role_order) VALUES (23, 'ROLE_USER_NEW_MEMBER', 'ROLE_DESCRIPTION_USER_NEW_MEMBER', 'u_', 6);
INSERT INTO phpbb_acl_roles (role_id, role_name, role_description, role_type, role_order) VALUES (24, 'ROLE_FORUM_NEW_MEMBER', 'ROLE_DESCRIPTION_FORUM_NEW_MEMBER', 'f_', 10);
