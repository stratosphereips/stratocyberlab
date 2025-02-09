create table phpbb_bots
(
    bot_id     INTEGER
        primary key autoincrement,
    bot_active INTEGER UNSIGNED default '1' not null,
    bot_name   TEXT(65535)      default ''  not null,
    user_id    INTEGER UNSIGNED default '0' not null,
    bot_agent  VARCHAR(255)     default ''  not null,
    bot_ip     VARCHAR(255)     default ''  not null
);

create index phpbb_bots_bot_active
    on phpbb_bots (bot_active);

INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (1, 1, 'AdsBot [Google]', 3, 'AdsBot-Google', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (2, 1, 'Ahrefs [Bot]', 4, 'AhrefsBot/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (3, 1, 'Alexa [Bot]', 5, 'ia_archiver', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (4, 1, 'Alta Vista [Bot]', 6, 'Scooter/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (5, 1, 'Amazon [Bot]', 7, 'Amazonbot/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (6, 1, 'Ask Jeeves [Bot]', 8, 'Ask Jeeves', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (7, 1, 'Baidu [Spider]', 9, 'Baiduspider', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (8, 1, 'Bing [Bot]', 10, 'bingbot/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (9, 1, 'DuckDuckGo [Bot]', 11, 'DuckDuckBot/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (10, 1, 'Exabot [Bot]', 12, 'Exabot/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (11, 1, 'FAST Enterprise [Crawler]', 13, 'FAST Enterprise Crawler', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (12, 1, 'FAST WebCrawler [Crawler]', 14, 'FAST-WebCrawler/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (13, 1, 'Francis [Bot]', 15, 'http://www.neomo.de/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (14, 1, 'Gigabot [Bot]', 16, 'Gigabot/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (15, 1, 'Google Adsense [Bot]', 17, 'Mediapartners-Google', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (16, 1, 'Google Desktop', 18, 'Google Desktop', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (17, 1, 'Google Feedfetcher', 19, 'Feedfetcher-Google', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (18, 1, 'Google [Bot]', 20, 'Googlebot', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (19, 1, 'Heise IT-Markt [Crawler]', 21, 'heise-IT-Markt-Crawler', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (20, 1, 'Heritrix [Crawler]', 22, 'heritrix/1.', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (21, 1, 'IBM Research [Bot]', 23, 'ibm.com/cs/crawler', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (22, 1, 'ICCrawler - ICjobs', 24, 'ICCrawler - ICjobs', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (23, 1, 'ichiro [Crawler]', 25, 'ichiro/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (24, 1, 'Majestic-12 [Bot]', 26, 'MJ12bot/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (25, 1, 'Metager [Bot]', 27, 'MetagerBot/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (26, 1, 'MSN NewsBlogs', 28, 'msnbot-NewsBlogs/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (27, 1, 'MSN [Bot]', 29, 'msnbot/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (28, 1, 'MSNbot Media', 30, 'msnbot-media/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (29, 1, 'NG-Search [Bot]', 31, 'NG-Search/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (30, 1, 'Nutch [Bot]', 32, 'http://lucene.apache.org/nutch/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (31, 1, 'Nutch/CVS [Bot]', 33, 'NutchCVS/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (32, 1, 'OmniExplorer [Bot]', 34, 'OmniExplorer_Bot/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (33, 1, 'Online link [Validator]', 35, 'online link validator', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (34, 1, 'psbot [Picsearch]', 36, 'psbot/0', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (35, 1, 'Seekport [Bot]', 37, 'Seekbot/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (36, 1, 'Semrush [Bot]', 38, 'SemrushBot/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (37, 1, 'Sensis [Crawler]', 39, 'Sensis Web Crawler', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (38, 1, 'SEO Crawler', 40, 'SEO search Crawler/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (39, 1, 'Seoma [Crawler]', 41, 'Seoma [SEO Crawler]', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (40, 1, 'SEOSearch [Crawler]', 42, 'SEOsearch/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (41, 1, 'Snappy [Bot]', 43, 'Snappy/1.1 ( http://www.urltrends.com/ )', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (42, 1, 'Steeler [Crawler]', 44, 'http://www.tkl.iis.u-tokyo.ac.jp/~crawler/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (43, 1, 'Synoo [Bot]', 45, 'SynooBot/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (44, 1, 'Telekom [Bot]', 46, 'crawleradmin.t-info@telekom.de', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (45, 1, 'TurnitinBot [Bot]', 47, 'TurnitinBot/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (46, 1, 'Voyager [Bot]', 48, 'voyager/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (47, 1, 'W3 [Sitesearch]', 49, 'W3 SiteSearch Crawler', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (48, 1, 'W3C [Linkcheck]', 50, 'W3C-checklink/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (49, 1, 'W3C [Validator]', 51, 'W3C_*Validator', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (50, 1, 'WiseNut [Bot]', 52, 'http://www.WISEnutbot.com', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (51, 1, 'YaCy [Bot]', 53, 'yacybot', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (52, 1, 'Yahoo MMCrawler [Bot]', 54, 'Yahoo-MMCrawler/', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (53, 1, 'Yahoo Slurp [Bot]', 55, 'Yahoo! DE Slurp', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (54, 1, 'Yahoo [Bot]', 56, 'Yahoo! Slurp', '');
INSERT INTO phpbb_bots (bot_id, bot_active, bot_name, user_id, bot_agent, bot_ip) VALUES (55, 1, 'YahooSeeker [Bot]', 57, 'YahooSeeker/', '');
