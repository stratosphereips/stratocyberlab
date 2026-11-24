FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server sudo cron rsyslog bash ca-certificates && rm -rf /var/lib/apt/lists/* && mkdir -p /run/sshd
RUN useradd -m -s /bin/bash analyst && echo 'analyst:neon-archive-74' | chpasswd && usermod -aG sudo analyst && printf 'analyst ALL=(ALL) NOPASSWD: ALL\n' > /etc/sudoers.d/analyst && chmod 0440 /etc/sudoers.d/analyst
RUN useradd -m -s /bin/bash retro && echo 'retro:quiet-boot-19' | chpasswd && useradd -m -s /bin/bash archivist && echo 'archivist:paper-moon-52' | chpasswd && useradd -m -s /bin/bash buildbot && echo 'buildbot:compile-dust-31' | chpasswd
RUN mkdir -p /home/retro/.ssh /home/archivist /home/buildbot /var/log && chown -R retro:retro /home/retro && chmod 700 /home/retro/.ssh
RUN printf '\nPasswordAuthentication yes\nPermitRootLogin no\nUsePAM no\nAllowUsers analyst\n' >> /etc/ssh/sshd_config
COPY plant.sh /tmp/plant.sh
RUN bash /tmp/plant.sh && rm -f /tmp/plant.sh && ssh-keygen -A
EXPOSE 22
