FROM httpd:2.4-buster

# Environment
ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

# Point apt sources to Debian archive (since buster is EOL)
RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list && \
    sed -i '/security.debian.org/d' /etc/apt/sources.list && \
    apt-get update -o Acquire::Check-Valid-Until=false -y

# Install wget, procps, and libtinfo5 (available in buster archive)
RUN apt-get install -y wget procps libtinfo5

# Install vulnerable bash version from Debian snapshot
RUN wget http://snapshot.debian.org/archive/debian/20130101T091755Z/pool/main/b/bash/bash_4.2%2Bdfsg-0.1_amd64.deb -O /tmp/bash.deb && \
    dpkg -i /tmp/bash.deb || apt-get -f install -y

# Setup cgi capabilities for httpd
COPY httpd.conf /usr/local/apache2/conf/httpd.conf

# Setup cgi script
COPY report.sh /usr/local/apache2/cgi-bin/report
RUN chmod a+x /usr/local/apache2/cgi-bin/report

# Copy the index that points to the cgi script
COPY index.html /usr/local/apache2/htdocs/index.html

EXPOSE 80