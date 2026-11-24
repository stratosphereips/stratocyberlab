FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server cron sudo rsyslog ca-certificates netcat-openbsd && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /run/sshd /var/log /etc/cron.d && ssh-keygen -A
COPY plant.sh /usr/local/sbin/plant.sh
RUN chmod 0755 /usr/local/sbin/plant.sh && /usr/local/sbin/plant.sh && rm /usr/local/sbin/plant.sh
EXPOSE 22
