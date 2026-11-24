FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server sudo bash gcc libc6-dev python3 && rm -rf /var/lib/apt/lists/* && mkdir -p /run/sshd

RUN useradd --create-home --shell /bin/bash tech && echo 'tech:OrbitWrench!6' | chpasswd && usermod -aG users tech

COPY plant.sh /tmp/plant.sh
RUN bash /tmp/plant.sh && rm -f /tmp/plant.sh

RUN printf '%s\n' 'PermitRootLogin no' 'PasswordAuthentication yes' 'KbdInteractiveAuthentication no' 'UsePAM yes' > /etc/ssh/sshd_config.d/20-lab.conf && chmod 0755 /var/run/sshd
