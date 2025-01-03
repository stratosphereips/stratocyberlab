FROM debian:12 AS gobuilder

# Clean up existing sources
RUN rm -rf /etc/apt/sources.list /etc/apt/sources.list.d/*

# Add valid Debian repositories
RUN echo "deb http://deb.debian.org/debian bookworm main" > /etc/apt/sources.list && \
    echo "deb http://security.debian.org/debian-security bookworm-security main" >> /etc/apt/sources.list && \
    echo "deb http://deb.debian.org/debian bookworm-updates main" >> /etc/apt/sources.list

# Update and install required packages
RUN apt-get update -o Acquire::AllowInsecureRepositories=true && \
    apt-get install -y --no-install-recommends openssh-server rsyslog && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /var/run/sshd && mkdir -p /root/.ssh

# Copy SSH server configuration file
COPY sshd_config /etc/ssh/sshd_config

# Set root password
RUN echo "root:admin" | chpasswd

# Configure rsyslog to forward logs to class14
RUN echo '$ModLoad imudp' >> /etc/rsyslog.conf && \
    echo '$UDPServerRun 514' >> /etc/rsyslog.conf && \
    echo 'auth.* @172.20.0.5:514' > /etc/rsyslog.d/remote-logging.conf

# Ensure SSH logging is verbose
RUN echo "LogLevel VERBOSE" >> /etc/ssh/sshd_config

# Expose SSH port
EXPOSE 22

# Start rsyslog and SSH server when the container starts
CMD service rsyslog start && /usr/sbin/sshd -D
