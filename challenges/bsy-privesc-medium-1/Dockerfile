FROM debian:bookworm

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends openssh-server sudo python3 gcc libc6-dev iproute2 \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/sshd

COPY build-check.c /tmp/build-check.c
COPY queue-status.c /tmp/queue-status.c
COPY plant.sh /tmp/plant.sh

RUN gcc -O2 -Wall -Wextra -o /usr/local/bin/build-check /tmp/build-check.c \
    && gcc -O2 -Wall -Wextra -o /usr/local/bin/queue-status /tmp/queue-status.c \
    && bash /tmp/plant.sh \
    && rm -f /tmp/plant.sh /tmp/build-check.c /tmp/queue-status.c \
    && ssh-keygen -A

CMD ["/usr/sbin/sshd", "-D", "-e"]
