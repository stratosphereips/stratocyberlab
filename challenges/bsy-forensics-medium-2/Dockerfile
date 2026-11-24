FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server cron sudo python3 ca-certificates && rm -rf /var/lib/apt/lists/* && mkdir -p /run/sshd
COPY sshd_config /etc/ssh/sshd_config
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY plant.sh /tmp/plant.sh
RUN chmod 755 /usr/local/bin/entrypoint.sh /tmp/plant.sh && /tmp/plant.sh && rm /tmp/plant.sh
