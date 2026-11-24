FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server openssh-client cron sudo ca-certificates && rm -rf /var/lib/apt/lists/* && mkdir -p /run/sshd
RUN printf '%s\n' 'root:NeonBoard-47!' | chpasswd
RUN sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
COPY service/plant.sh /tmp/plant.sh
RUN chmod 755 /tmp/plant.sh && /bin/bash /tmp/plant.sh && rm -f /tmp/plant.sh
EXPOSE 22
