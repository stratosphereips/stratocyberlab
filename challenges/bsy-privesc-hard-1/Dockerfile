FROM debian:bookworm

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends openssh-server sudo findutils ca-certificates && rm -rf /var/lib/apt/lists/*

COPY plant.sh /tmp/plant.sh
RUN bash /tmp/plant.sh && rm -f /tmp/plant.sh && mkdir -p /run/sshd

CMD ["/usr/sbin/sshd", "-D", "-e"]
