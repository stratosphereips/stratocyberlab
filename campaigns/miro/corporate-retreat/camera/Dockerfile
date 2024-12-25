FROM rtsp/lighttpd:1.4.76

COPY webroot/* /var/www/html
COPY lighttpd-conf/* /etc/lighttpd/conf.d/
COPY delay.lua /etc/lighttpd/

RUN sed -i '$a$HTTP["url"]=~ ".*admin.*" { url.access-deny = ( "" ) }' /etc/lighttpd/conf.d/11-access.conf
