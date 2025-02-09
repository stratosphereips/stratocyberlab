create table phpbb_posts
(
    post_id            INTEGER
        primary key autoincrement,
    topic_id           INTEGER UNSIGNED     default '0' not null,
    forum_id           INTEGER UNSIGNED     default '0' not null,
    poster_id          INTEGER UNSIGNED     default '0' not null,
    icon_id            INTEGER UNSIGNED     default '0' not null,
    poster_ip          VARCHAR(40)          default ''  not null,
    post_time          INTEGER UNSIGNED     default '0' not null,
    post_reported      INTEGER UNSIGNED     default '0' not null,
    enable_bbcode      INTEGER UNSIGNED     default '1' not null,
    enable_smilies     INTEGER UNSIGNED     default '1' not null,
    enable_magic_url   INTEGER UNSIGNED     default '1' not null,
    enable_sig         INTEGER UNSIGNED     default '1' not null,
    post_username      VARCHAR(255)         default ''  not null,
    post_subject       TEXT(65535)          default ''  not null,
    post_text          MEDIUMTEXT(16777215) default ''  not null,
    post_checksum      VARCHAR(32)          default ''  not null,
    post_attachment    INTEGER UNSIGNED     default '0' not null,
    bbcode_bitfield    VARCHAR(255)         default ''  not null,
    bbcode_uid         VARCHAR(8)           default ''  not null,
    post_postcount     INTEGER UNSIGNED     default '1' not null,
    post_edit_time     INTEGER UNSIGNED     default '0' not null,
    post_edit_reason   TEXT(65535)          default ''  not null,
    post_edit_user     INTEGER UNSIGNED     default '0' not null,
    post_edit_count    INTEGER UNSIGNED     default '0' not null,
    post_edit_locked   INTEGER UNSIGNED     default '0' not null,
    post_visibility    TINYINT(3)           default '0' not null,
    post_delete_time   INTEGER UNSIGNED     default '0' not null,
    post_delete_reason TEXT(65535)          default ''  not null,
    post_delete_user   INTEGER UNSIGNED     default '0' not null
);

create index phpbb_posts_forum_id
    on phpbb_posts (forum_id);

create index phpbb_posts_post_username
    on phpbb_posts (post_username);

create index phpbb_posts_post_visibility
    on phpbb_posts (post_visibility);

create index phpbb_posts_poster_id
    on phpbb_posts (poster_id);

create index phpbb_posts_poster_ip
    on phpbb_posts (poster_ip);

create index phpbb_posts_tid_post_time
    on phpbb_posts (topic_id, post_time);

create index phpbb_posts_topic_id
    on phpbb_posts (topic_id);

INSERT INTO phpbb_posts (post_id, topic_id, forum_id, poster_id, icon_id, poster_ip, post_time, post_reported, enable_bbcode, enable_smilies, enable_magic_url, enable_sig, post_username, post_subject, post_text, post_checksum, post_attachment, bbcode_bitfield, bbcode_uid, post_postcount, post_edit_time, post_edit_reason, post_edit_user, post_edit_count, post_edit_locked, post_visibility, post_delete_time, post_delete_reason, post_delete_user) VALUES (5, 3, 14, 59, 0, '192.168.65.1', 1736079664, 0, 1, 1, 1, 1, '', 'Seeking Assistance with a Disruptive Individual', '<t>Hey all, <br/>
<br/>
I''m Vigilante88 and I need some help dealing with a problematic individual who''s been causing trouble for my organization. This person has been spreading misinformation and engaging in activities that are detrimental to our interests. <br/>
<br/>
Our internal efforts haven''t yielded the desired results, and I fear this person will continue their campaign unless we get outside assistance. <br/>
<br/>
I''m looking for someone with knowledge or connections that could lead to legal consequences for this individual. My involvement needs to remain confidential, so discretion is crucial. <br/>
<br/>
If anyone has relevant information, skills, or just wants to lend a hand, please reply and let''s discuss the details. <br/>
<br/>
Thanks</t>', 'cfdd0c1de5f451693eb30b5f493ad95a', 0, '', '6j0x', 1, 0, '', 0, 0, 0, 1, 0, '', 0);
INSERT INTO phpbb_posts (post_id, topic_id, forum_id, poster_id, icon_id, poster_ip, post_time, post_reported, enable_bbcode, enable_smilies, enable_magic_url, enable_sig, post_username, post_subject, post_text, post_checksum, post_attachment, bbcode_bitfield, bbcode_uid, post_postcount, post_edit_time, post_edit_reason, post_edit_user, post_edit_count, post_edit_locked, post_visibility, post_delete_time, post_delete_reason, post_delete_user) VALUES (6, 3, 14, 60, 0, '192.168.65.1', 1736079823, 0, 1, 1, 1, 1, '', 'Re: Seeking Assistance with a Disruptive Individual', '<r>Oh boy, another corporate executive crying about "misinformation" and needing a hack to silence critics. <br/>
<br/>
Listen up, Vigilante88: 
<LIST><s>[list]</s>
<LI><s>[*]</s> If you''re so concerned about your organization''s reputation, maybe try addressing actual issues instead of trying to suppress criticism.</LI>
<LI><s>[*]</s> If you can''t handle the heat, get out of the kitchen. Or better yet, stop trying to control the narrative and let the truth speak for itself.</LI><e>[/list]</e></LIST>
     <br/>
As for help, I''m not in the business of silencing people just because they disagree with your corporate agenda. But hey, if you''re looking for a real challenge, try engaging in an open debate instead of trying to manipulate public opinion through backroom deals or hacking.</r>', '1633a4a7a160fe17d9f03d5976e174c8', 0, '', '5vacdxa', 1, 0, '', 0, 0, 0, 1, 0, '', 0);
INSERT INTO phpbb_posts (post_id, topic_id, forum_id, poster_id, icon_id, poster_ip, post_time, post_reported, enable_bbcode, enable_smilies, enable_magic_url, enable_sig, post_username, post_subject, post_text, post_checksum, post_attachment, bbcode_bitfield, bbcode_uid, post_postcount, post_edit_time, post_edit_reason, post_edit_user, post_edit_count, post_edit_locked, post_visibility, post_delete_time, post_delete_reason, post_delete_user) VALUES (7, 3, 14, 61, 0, '192.168.65.1', 1736079964, 0, 1, 1, 1, 1, '', 'Re: Seeking Assistance with a Disruptive Individual', '<r>Hey Vigilante88, <br/>
<br/>
I can relate to your frustration. I''ve seen many orgs get dragged through the mud by a single determined individual. <br/>
<br/>
As for taking down this person, I think you have a few options l0l: <br/>

<LIST type="decimal"><s>[list=1]</s>
<LI><s>[*]</s>    Social engineering - if you know their habits and can get them to reveal some juicy info, that could be useful in discrediting them.</LI>
<LI><s>[*]</s>    OSINT - gather as much public data on this person as possible and use it to create a narrative that''s harder for them to combat.</LI>
<LI><s>[*]</s>    Web scraping - scrape all the posts, comments, and mentions of your org online, then analyze the data to identify patterns or weaknesses you can exploit.</LI>
<e>[/list]</e></LIST>
     <br/>
<br/>
These are just general ideas, I''m not committing to helping you out personally (I''ve got better things to do). But maybe these suggestions will give you some food for thought. <br/>
<br/>
Best of luck,<br/>
G00dLuckCharlie</r>', '0a8dde0ce61f7c350d770b0323f2e96a', 0, '', '1v4sx03', 1, 0, '', 0, 0, 0, 1, 0, '', 0);
INSERT INTO phpbb_posts (post_id, topic_id, forum_id, poster_id, icon_id, poster_ip, post_time, post_reported, enable_bbcode, enable_smilies, enable_magic_url, enable_sig, post_username, post_subject, post_text, post_checksum, post_attachment, bbcode_bitfield, bbcode_uid, post_postcount, post_edit_time, post_edit_reason, post_edit_user, post_edit_count, post_edit_locked, post_visibility, post_delete_time, post_delete_reason, post_delete_user) VALUES (8, 3, 14, 62, 0, '192.168.65.1', 1736080014, 0, 1, 1, 1, 1, '', 'Re: Seeking Assistance with a Disruptive Individual', '<t>Wut''s g0ing on Vigilante88?! <br/>
<br/>
I c4n h3lp y0u t4k d0wn th1s p3rson w1th mY 0p3rtun1t3 sK1llz!!! <br/>
<br/>
I''ll n33d $10,000 f00d ch34n3r p31c3 + 5% c0mm15s1on + a d3dic4ted l1nk t0 y0ur org''s w3b s1t3 <br/>
<br/>
If y0u''r3 r4dy t0 m4k3 th1s h4pp3n, jUsT pM mE!!!</t>', '49ea461dbac5f8f5063619ce38da8ff5', 0, '', 'bmmfhi', 1, 0, '', 0, 0, 0, 1, 0, '', 0);
INSERT INTO phpbb_posts (post_id, topic_id, forum_id, poster_id, icon_id, poster_ip, post_time, post_reported, enable_bbcode, enable_smilies, enable_magic_url, enable_sig, post_username, post_subject, post_text, post_checksum, post_attachment, bbcode_bitfield, bbcode_uid, post_postcount, post_edit_time, post_edit_reason, post_edit_user, post_edit_count, post_edit_locked, post_visibility, post_delete_time, post_delete_reason, post_delete_user) VALUES (9, 3, 14, 63, 0, '192.168.65.1', 1736080282, 0, 1, 1, 1, 1, '', 'Re: Seeking Assistance with a Disruptive Individual', '<r>This thread has been locked due to excessive commercialism in violation of rule 3: "No soliciting or advertising for personal gain, including but not limited to, services, products, or donations." <br/>

<QUOTE author="B4dW0lf" post_id="8" time="1736080014" user_id="62"><s>[quote=B4dW0lf post_id=8 time=1736080014 user_id=62]</s>
I''ll n33d $10,000
<e>[/quote]</e></QUOTE>

The original poster''s request for assistance was acceptable, but subsequent posts that demanded payment or offered services for a fee have crossed the line. We encourage all users to focus on constructive discussions and avoid self-promotion.</r>', '1366bc30e8ef61a5cfd1e8801e841e9a', 0, '', 'bgaui', 1, 0, '', 0, 0, 0, 1, 0, '', 0);
