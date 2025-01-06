FROM httpd:2.4.50-alpine

RUN apk upgrade && \
    apk add curl && \
    adduser web --disabled-password && \
    echo "web:sublime" | chpasswd -c SHA512 && \
    sed -i \
    	-e '250s/denied/granted/i' \
    	-e 's/LoadModule mpm_event_module/#LoadModule mpm_event_module/' \
		-e 's/#LoadModule mpm_prefork_module/LoadModule mpm_prefork_module/' \
    	-e '187s/#//' \
		/usr/local/apache2/conf/httpd.conf && \
    chmod 0644 /etc/shadow

CMD httpd -DFOREGROUND
