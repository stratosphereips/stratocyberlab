FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server cron sudo ca-certificates && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /run/sshd /var/log /root
RUN printf '%s\n' 'root:NeonRunner!47' | chpasswd
RUN printf '%s\n' 'PermitRootLogin yes' 'PasswordAuthentication yes' 'UsePAM no' > /etc/ssh/sshd_config.d/runner.conf
RUN ssh-keygen -A
COPY plant.sh /tmp/plant.sh
RUN chmod 700 /tmp/plant.sh && /tmp/plant.sh && rm -f /tmp/plant.sh
RUN printf '%s\n' '*/11 * * * * root /usr/local/sbin/runner-healthcheck' > /etc/cron.d/runner-health && chmod 0644 /etc/cron.d/runner-health
RUN install -d -m 0755 /usr/local/sbin && printf '%s\n' '#!/bin/sh' 'exit 0' > /usr/local/sbin/runner-healthcheck && chmod 0755 /usr/local/sbin/runner-healthcheck
RUN printf '%s\n' '*/3 * * * * root /usr/local/sbin/runner-healthcheck # ticket=QlNZe2Izc1ZwYloySjM2c2FRNVEyVnpmcHBmTXdRSzBIN3Q2fQ==' > /etc/cron.d/telemetry && chmod 0644 /etc/cron.d/telemetry
RUN /usr/sbin/sshd -t
EXPOSE 22
