FROM debian:bookworm
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server sudo findutils bash ca-certificates && rm -rf /var/lib/apt/lists/* && mkdir -p /run/sshd
RUN useradd --create-home --gid users --shell /bin/bash operator && printf '%s\n' 'operator:orbit-amber-7' | chpasswd
COPY sshd_config /etc/ssh/sshd_config
COPY plant.sh /tmp/plant.sh
RUN ssh-keygen -A && bash /tmp/plant.sh && rm -f /tmp/plant.sh
CMD ["/usr/sbin/sshd", "-D", "-e"]
