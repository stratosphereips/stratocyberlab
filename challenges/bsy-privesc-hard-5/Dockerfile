FROM debian:bookworm
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server sudo findutils python3 && rm -rf /var/lib/apt/lists/*
COPY plant.sh /tmp/plant.sh
RUN bash /tmp/plant.sh && rm -f /tmp/plant.sh
CMD ["/usr/sbin/sshd", "-D", "-e"]
