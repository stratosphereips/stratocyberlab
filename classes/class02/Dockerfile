FROM python:3-slim

RUN apt-get update && apt-get install -y vsftpd && apt-get clean

RUN mkdir /var/www
RUN echo "<html><body><h1>Hello from HTTP Server</h1></body></html>" > /var/www/index.html

# Configure vsftpd and start FTP
RUN echo "listen=NO" >> /etc/vsftpd.conf && \
    echo "listen_ipv6=YES" >> /etc/vsftpd.conf && \
    echo "anonymous_enable=YES" >> /etc/vsftpd.conf && \
    echo "anon_root=/var/ftp" >> /etc/vsftpd.conf && \
    echo "local_enable=YES" >> /etc/vsftpd.conf && \
    mkdir /var/ftp && \
    echo "Hello from FTP server!" > /var/ftp/welcome.txt

COPY start.sh /start.sh
CMD /start.sh
