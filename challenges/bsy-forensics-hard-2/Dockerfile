FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server sudo cron ca-certificates && rm -rf /var/lib/apt/lists/*
COPY plant.sh /usr/local/sbin/plant.sh
RUN chmod 0755 /usr/local/sbin/plant.sh && /usr/local/sbin/plant.sh && rm /usr/local/sbin/plant.sh && mkdir -p /run/sshd && printf '\nPasswordAuthentication yes\nPermitRootLogin no\nUsePAM no\nAllowUsers analyst\n' >> /etc/ssh/sshd_config
EXPOSE 22
