FROM debian:bookworm
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server sudo python3 ca-certificates && rm -rf /var/lib/apt/lists/* && mkdir -p /run/sshd
COPY plant.sh /tmp/plant.sh
RUN bash /tmp/plant.sh && rm -f /tmp/plant.sh && \
    cp /usr/bin/true /usr/local/bin/diag-note && \
    chown root:root /usr/local/bin/diag-note && chmod 4755 /usr/local/bin/diag-note && \
    ssh-keygen -A && \
    printf '%s\n' 'PermitRootLogin no' 'PasswordAuthentication yes' 'KbdInteractiveAuthentication no' 'UsePAM no' 'AllowUsers forge' >> /etc/ssh/sshd_config
HEALTHCHECK --interval=10s --timeout=3s --retries=5 CMD python3 -c "import socket; s=socket.create_connection(('127.0.0.1',22),2); s.close()"
CMD ["/usr/sbin/sshd", "-D", "-e"]
