FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends openssh-server cron sudo netcat-openbsd \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/sshd /var/log

RUN printf '%s\n' \
      'PermitRootLogin yes' \
      'PasswordAuthentication yes' \
      'KbdInteractiveAuthentication no' \
      'UsePAM no' \
      'AllowUsers root' \
      > /etc/ssh/sshd_config \
    && ssh-keygen -A \
    && echo 'root:stargate-operator-7' | chpasswd

COPY plant.sh /usr/local/sbin/plant.sh
RUN chmod 0755 /usr/local/sbin/plant.sh && /usr/local/sbin/plant.sh

HEALTHCHECK --interval=10s --timeout=3s --retries=5 CMD nc -z 127.0.0.1 22
