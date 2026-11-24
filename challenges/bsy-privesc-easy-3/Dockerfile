FROM debian:bookworm
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -o Acquire::Retries=3 && apt-get install -y --no-install-recommends openssh-server sudo findutils bash && rm -rf /var/lib/apt/lists/*
RUN useradd -m -s /bin/bash cityops && printf '%s:%s\n' cityops 'NeonTransit-47' | chpasswd && mkdir -p /run/sshd
COPY sshd_config /etc/ssh/sshd_config
COPY plant.sh /tmp/plant.sh
RUN bash /tmp/plant.sh && rm -f /tmp/plant.sh && ssh-keygen -A && /usr/sbin/sshd -t
