create table phpbb_smilies
(
    smiley_id          INTEGER
        primary key autoincrement,
    code               VARCHAR(50)      default ''  not null,
    emotion            VARCHAR(255)     default ''  not null,
    smiley_url         VARCHAR(50)      default ''  not null,
    smiley_width       INTEGER UNSIGNED default '0' not null,
    smiley_height      INTEGER UNSIGNED default '0' not null,
    smiley_order       INTEGER UNSIGNED default '0' not null,
    display_on_posting INTEGER UNSIGNED default '1' not null
);

create index phpbb_smilies_display_on_post
    on phpbb_smilies (display_on_posting);

INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (1, ':D', 'Very Happy', 'icon_e_biggrin.gif', 15, 17, 1, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (2, ':-D', 'Very Happy', 'icon_e_biggrin.gif', 15, 17, 2, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (3, ':grin:', 'Very Happy', 'icon_e_biggrin.gif', 15, 17, 3, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (4, ':)', 'Smile', 'icon_e_smile.gif', 15, 17, 4, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (5, ':-)', 'Smile', 'icon_e_smile.gif', 15, 17, 5, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (6, ':smile:', 'Smile', 'icon_e_smile.gif', 15, 17, 6, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (7, ';)', 'Wink', 'icon_e_wink.gif', 15, 17, 7, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (8, ';-)', 'Wink', 'icon_e_wink.gif', 15, 17, 8, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (9, ':wink:', 'Wink', 'icon_e_wink.gif', 15, 17, 9, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (10, ':(', 'Sad', 'icon_e_sad.gif', 15, 17, 10, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (11, ':-(', 'Sad', 'icon_e_sad.gif', 15, 17, 11, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (12, ':sad:', 'Sad', 'icon_e_sad.gif', 15, 17, 12, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (13, ':o', 'Surprised', 'icon_e_surprised.gif', 15, 17, 13, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (14, ':-o', 'Surprised', 'icon_e_surprised.gif', 15, 17, 14, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (15, ':eek:', 'Surprised', 'icon_e_surprised.gif', 15, 17, 15, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (16, ':shock:', 'Shocked', 'icon_eek.gif', 15, 17, 16, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (17, ':?', 'Confused', 'icon_e_confused.gif', 15, 17, 17, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (18, ':-?', 'Confused', 'icon_e_confused.gif', 15, 17, 18, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (19, ':???:', 'Confused', 'icon_e_confused.gif', 15, 17, 19, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (20, '8-)', 'Cool', 'icon_cool.gif', 15, 17, 20, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (21, ':cool:', 'Cool', 'icon_cool.gif', 15, 17, 21, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (22, ':lol:', 'Laughing', 'icon_lol.gif', 15, 17, 22, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (23, ':x', 'Mad', 'icon_mad.gif', 15, 17, 23, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (24, ':-x', 'Mad', 'icon_mad.gif', 15, 17, 24, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (25, ':mad:', 'Mad', 'icon_mad.gif', 15, 17, 25, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (26, ':P', 'Razz', 'icon_razz.gif', 15, 17, 26, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (27, ':-P', 'Razz', 'icon_razz.gif', 15, 17, 27, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (28, ':razz:', 'Razz', 'icon_razz.gif', 15, 17, 28, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (29, ':oops:', 'Embarrassed', 'icon_redface.gif', 15, 17, 29, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (30, ':cry:', 'Crying or Very Sad', 'icon_cry.gif', 15, 17, 30, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (31, ':evil:', 'Evil or Very Mad', 'icon_evil.gif', 15, 17, 31, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (32, ':twisted:', 'Twisted Evil', 'icon_twisted.gif', 15, 17, 32, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (33, ':roll:', 'Rolling Eyes', 'icon_rolleyes.gif', 15, 17, 33, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (34, ':!:', 'Exclamation', 'icon_exclaim.gif', 15, 17, 34, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (35, ':?:', 'Question', 'icon_question.gif', 15, 17, 35, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (36, ':idea:', 'Idea', 'icon_idea.gif', 15, 17, 36, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (37, ':arrow:', 'Arrow', 'icon_arrow.gif', 15, 17, 37, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (38, ':|', 'Neutral', 'icon_neutral.gif', 15, 17, 38, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (39, ':-|', 'Neutral', 'icon_neutral.gif', 15, 17, 39, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (40, ':mrgreen:', 'Mr. Green', 'icon_mrgreen.gif', 15, 17, 40, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (41, ':geek:', 'Geek', 'icon_e_geek.gif', 17, 17, 41, 1);
INSERT INTO phpbb_smilies (smiley_id, code, emotion, smiley_url, smiley_width, smiley_height, smiley_order, display_on_posting) VALUES (42, ':ugeek:', 'Uber Geek', 'icon_e_ugeek.gif', 17, 18, 42, 1);
