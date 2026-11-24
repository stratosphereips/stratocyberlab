FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server cron sudo netcat-openbsd && rm -rf /var/lib/apt/lists/* && mkdir -p /run/sshd /var/log
COPY plant.sh /usr/local/sbin/plant-challenge
RUN chmod 0755 /usr/local/sbin/plant-challenge && /usr/local/sbin/plant-challenge && rm /usr/local/sbin/plant-challenge
EXPOSE 22
