FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server sudo cron netcat-openbsd ca-certificates && rm -rf /var/lib/apt/lists/*

COPY plant.sh /usr/local/sbin/plant-challenge
COPY start-sshd.sh /usr/local/sbin/start-sshd
RUN chmod 0755 /usr/local/sbin/plant-challenge /usr/local/sbin/start-sshd \
    && /usr/local/sbin/plant-challenge \
    && rm /usr/local/sbin/plant-challenge

CMD ["/usr/local/sbin/start-sshd"]
