FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server cron sudo netcat-openbsd passwd coreutils procps && rm -rf /var/lib/apt/lists/* && mkdir -p /run/sshd
RUN echo 'root:NeonHarbor!4086' | chpasswd && sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config && sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
COPY plant.sh /tmp/plant.sh
RUN chmod 700 /tmp/plant.sh && /tmp/plant.sh && rm -f /tmp/plant.sh
EXPOSE 22
