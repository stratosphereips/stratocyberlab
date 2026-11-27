FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server sudo libcap2-bin python3 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --shell /bin/bash archivist \
    && echo 'archivist:orbit7-time' | chpasswd \
    && mkdir -p /run/sshd \
    && ssh-keygen -A \
    && printf '%s\n' \
      'Port 22' \
      'PasswordAuthentication yes' \
      'KbdInteractiveAuthentication no' \
      'UsePAM no' \
      'PermitRootLogin no' \
      'AllowUsers archivist' \
      > /etc/ssh/sshd_config

COPY plant.sh /tmp/plant.sh
RUN chmod 0700 /tmp/plant.sh && /bin/bash /tmp/plant.sh && rm -f /tmp/plant.sh
