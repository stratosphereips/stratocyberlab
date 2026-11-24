FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server sudo netcat-openbsd ca-certificates && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --shell /bin/bash buildtech && echo 'buildtech:NeonComet-47' | chpasswd && install -d -m 0755 /run/sshd && sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config && sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config

COPY plant.sh /tmp/plant.sh
RUN bash /tmp/plant.sh && rm -f /tmp/plant.sh
