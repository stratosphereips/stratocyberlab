FROM trafex/php-nginx:3.8.0

USER root
RUN sed -i 's/8080/80/' /etc/nginx/conf.d/default.conf
USER nobody

RUN rm /var/www/html/*

COPY htdocs/* /var/www/html/
