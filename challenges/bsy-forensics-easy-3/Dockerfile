FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends openssh-server cron sudo bash \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/sshd

RUN echo 'root:NeonRunner-7F' | chpasswd \
    && printf '\nPermitRootLogin yes\nPasswordAuthentication yes\n' >> /etc/ssh/sshd_config \
    && ssh-keygen -A

COPY plant.sh /usr/local/sbin/plant.sh
RUN chmod 700 /usr/local/sbin/plant.sh \
    && /usr/local/sbin/plant.sh \
    && rm -f /usr/local/sbin/plant.sh
