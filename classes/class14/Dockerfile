FROM debian:12 AS gobuilder

# Install necessary packages
RUN apt update && apt install -y --no-install-recommends \
    openssh-server tmux vim nano rsyslog git python3-pip python3.11-venv && \
    apt clean && rm -rf /var/lib/apt/lists/*


# Create necessary directories
RUN mkdir -p /var/run/sshd /root/.ssh

# Copy SSH server configuration file
COPY sshd_config /etc/ssh/sshd_config

# Set environment variables
ENV TERM=xterm-256color
RUN echo "PS1='\e[92m\u\e[0m@\e[94m\h\e[0m:\e[35m\w\e[0m# '" >> /root/.bashrc && \
    echo "export LC_CTYPE=C.UTF-8" >> /root/.bashrc  # for gef

# Set root password
RUN echo "root:admin" | chpasswd

# Configure rsyslog to receive logs
RUN echo '$ModLoad imudp' >> /etc/rsyslog.conf && \
    echo '$UDPServerRun 514' >> /etc/rsyslog.conf && \
    echo '$ModLoad imtcp' >> /etc/rsyslog.conf && \
    echo '$InputTCPServerRun 514' >> /etc/rsyslog.conf

# Expose SSH and rsyslog ports
EXPOSE 22 514

# Use a script to start both rsyslog and sshd
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

