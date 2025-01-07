FROM cicirello/gnu-on-alpine:3.20.3 AS log-generator

# generate a lot of logs with rubbish content
COPY rubbish-log-generator /tmp
RUN cd /tmp && \
    sh log-randomizer.sh && \
    mkdir rubbish-logs && \
    mv *.log rubbish-logs/

FROM httpd:2.4.50-alpine

RUN apk upgrade && \
    apk add php8-apache2 sudo openssh-server curl && \
    adduser web --disabled-password && \
    echo "web:sublime" | chpasswd -c SHA512 && \
    sed -i \
		-e 's/User daemon/User web/' \
		-e 's/Group daemon/Group web/' \
    	-e 's/LoadModule mpm_event_module/#LoadModule mpm_event_module/' \
		-e 's/#LoadModule mpm_prefork_module/LoadModule mpm_prefork_module/' \
    	-e '200i LoadModule php_module /usr/lib/apache2/mod_php8.so' \
    	-e '293i AddHandler php-script .php' \
		/usr/local/apache2/conf/httpd.conf && \
    mkdir /var/log/dashboard && \
    chown -R web:web /var/log/dashboard && \
    ssh-keygen -A

COPY log.php /usr/local/apache2/htdocs/log.php
COPY --from=log-generator /tmp/rubbish-logs/ /var/log/dashboard/
COPY proxy2021-12-09.log /var/log/dashboard/

CMD /usr/sbin/sshd && httpd -DFOREGROUND
