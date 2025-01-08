FROM debian:12 AS gobuilder

# Clean up existing sources and add valid Debian repositories
RUN rm -rf /etc/apt/sources.list /etc/apt/sources.list.d/* && \
    echo "deb http://deb.debian.org/debian bookworm main" > /etc/apt/sources.list && \
    echo "deb http://security.debian.org/debian-security bookworm-security main" >> /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian bookworm-updates main" >> /etc/apt/sources.list

# Update and install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends openssh-server rsyslog && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /var/run/sshd && mkdir -p /root/.ssh

# Copy SSH server configuration file
COPY sshd_config /etc/ssh/sshd_config

# Set root password
RUN echo "root:admin" | chpasswd

# Configure rsyslog to forward logs to a remote container
RUN echo '$ModLoad imudp' >> /etc/rsyslog.conf && \
    echo '$UDPServerRun 514' >> /etc/rsyslog.conf && \
    echo 'auth.* @class14:514' > /etc/rsyslog.d/remote-logging.conf

# Expose SSH port
EXPOSE 22

# Use a script to start rsyslog and SSH server
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
