FROM debian:bookworm-slim

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends openssh-server findutils \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/sshd

COPY sshd_config /etc/ssh/sshd_config
COPY plant.sh /tmp/plant.sh
RUN bash /tmp/plant.sh && rm -f /tmp/plant.sh

EXPOSE 22
