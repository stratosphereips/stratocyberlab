FROM golang:1.23.4-alpine3.20 AS go-build

COPY fastcgi-responder/ /root/
WORKDIR /root
RUN go build

FROM rtsp/lighttpd:1.4.76

COPY webroot/* /var/www/html
COPY lighttpd-conf/* /etc/lighttpd/conf.d/
COPY delay.lua /etc/lighttpd/
COPY --from=go-build /root/responder /etc/lighttpd/fastcgi-responder
COPY office.jpg /etc/lighttpd/
