FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server sudo findutils libcap2-bin ca-certificates && rm -rf /var/lib/apt/lists/*
COPY plant.sh /tmp/plant.sh
RUN bash /tmp/plant.sh && rm -f /tmp/plant.sh && mkdir -p /run/sshd && ssh-keygen -A
RUN printf '%s\n' 'PermitRootLogin no' 'PasswordAuthentication yes' 'KbdInteractiveAuthentication no' 'UsePAM no' 'AllowUsers rookie' > /etc/ssh/sshd_config.d/challenge.conf
EXPOSE 22
