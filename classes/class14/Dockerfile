FROM debian:12 AS gobuilder

# Install SSH server and packages including rsyslog
RUN apt update && \
    apt install -y openssh-server rsyslog vim tmux git \
                   python3 python3-pip && \
    apt clean

# Create necessary directories
RUN mkdir -p /var/run/sshd
RUN mkdir -p /root/.ssh

# Copy SSH server configuration file
COPY sshd_config /etc/ssh/sshd_config

# Set environment variables
ENV TERM=xterm-256color
RUN echo "PS1='\e[92m\u\e[0m@\e[94m\h\e[0m:\e[35m\w\e[0m# '" >> /root/.bashrc && \
    echo "export LC_CTYPE=C.UTF-8" >> /root/.bashrc  # for gef

RUN echo "root:admin" | chpasswd

# Configure rsyslog to receive logs
RUN echo '$ModLoad imudp' >> /etc/rsyslog.conf && \
    echo '$UDPServerRun 514' >> /etc/rsyslog.conf && \
    echo '$ModLoad imtcp' >> /etc/rsyslog.conf && \
    echo '$InputTCPServerRun 514' >> /etc/rsyslog.conf

# Expose SSH and rsyslog ports
EXPOSE 22 514

# Start rsyslog and SSH server when the container starts
CMD service rsyslog start && /usr/sbin/sshd -D
