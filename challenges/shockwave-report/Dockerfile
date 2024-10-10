FROM httpd:2.4

# Environment
ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

RUN apt-get update -y && apt-get dist-upgrade -y

# Install wget and a library needed for the vulnerable bash
RUN apt-get install -y wget libtinfo5 procps

# Install vulnerable bash version from wayback/snapshot archive
RUN wget http://snapshot.debian.org/archive/debian/20130101T091755Z/pool/main/b/bash/bash_4.2%2Bdfsg-0.1_amd64.deb -O /tmp/bash_4.2+dfsg-0.1_amd64.deb && \
 dpkg -i /tmp/bash_4.2+dfsg-0.1_amd64.deb

# Setup cgi capabilities for httpd
COPY httpd.conf /usr/local/apache2/conf/httpd.conf

# Setup cgi script
COPY report.sh /usr/local/apache2/cgi-bin/report
RUN chmod a+x /usr/local/apache2/cgi-bin/report

# Copy the index that points to the cgi script
COPY index.html /usr/local/apache2/htdocs/index.html

EXPOSE 80