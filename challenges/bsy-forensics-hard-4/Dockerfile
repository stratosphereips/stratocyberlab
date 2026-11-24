FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server cron sudo coreutils util-linux procps ca-certificates && rm -rf /var/lib/apt/lists/* && mkdir -p /run/sshd && printf '\nPermitRootLogin yes\nPasswordAuthentication yes\nUsePAM no\n' >> /etc/ssh/sshd_config && echo 'root:neonforge-44' | chpasswd
COPY plant.sh /usr/local/sbin/plant.sh
RUN chmod 0755 /usr/local/sbin/plant.sh && /usr/local/sbin/plant.sh && ssh-keygen -A
