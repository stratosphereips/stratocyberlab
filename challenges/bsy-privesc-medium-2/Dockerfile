FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server sudo python3 libcap2-bin gcc libc6-dev netcat-openbsd ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --shell /bin/bash orbit \
    && printf '%s:%s\n' 'orbit' 'vector-amber-42' | chpasswd \
    && printf '\nPasswordAuthentication yes\nPermitRootLogin no\n' >> /etc/ssh/sshd_config \
    && ssh-keygen -A

COPY plant.sh /tmp/plant.sh
COPY clockstamp.c /opt/challenge/clockstamp.c
RUN bash /tmp/plant.sh && rm -f /tmp/plant.sh
