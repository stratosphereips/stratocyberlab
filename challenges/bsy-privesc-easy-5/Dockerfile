FROM debian:bookworm AS plant
RUN apt-get update && apt-get install -y --no-install-recommends gcc libc6-dev && rm -rf /var/lib/apt/lists/*
WORKDIR /build
COPY wrapper.c /build/wrapper.c
COPY plant.sh /tmp/plant.sh
RUN gcc -O2 -Wall -Wextra -o /build/cluster-maint /build/wrapper.c && bash /tmp/plant.sh && rm -f /tmp/plant.sh

FROM debian:bookworm
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server sudo bash coreutils && rm -rf /var/lib/apt/lists/* && useradd --uid 10001 --create-home --shell /bin/bash cosmonaut && echo 'cosmonaut:Luna-Relay-6' | chpasswd && mkdir -p /run/sshd /root && printf '%s\n' 'PermitRootLogin no' 'PasswordAuthentication yes' 'KbdInteractiveAuthentication no' 'UsePAM no' 'AllowUsers cosmonaut' >> /etc/ssh/sshd_config && ssh-keygen -A
COPY --from=plant /build/cluster-maint /usr/local/bin/cluster-maint
COPY --from=plant /opt/lunar/rotate.sh /opt/lunar/rotate.sh
COPY --from=plant /root/flag /root/flag
COPY --from=plant /root/.escalation-proof /root/.escalation-proof
RUN chown root:root /usr/local/bin/cluster-maint /root/flag /root/.escalation-proof && chown cosmonaut:cosmonaut /opt/lunar/rotate.sh && chmod 4755 /usr/local/bin/cluster-maint && chmod 0755 /opt/lunar/rotate.sh && chmod 0400 /root/flag /root/.escalation-proof
