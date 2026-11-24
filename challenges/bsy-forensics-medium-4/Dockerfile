FROM debian:bookworm-slim

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends openssh-server cron sudo ca-certificates && rm -rf /var/lib/apt/lists/* && mkdir -p /run/sshd

COPY plant.sh /usr/local/sbin/plant-challenge
RUN chmod 0755 /usr/local/sbin/plant-challenge && /usr/local/sbin/plant-challenge && rm /usr/local/sbin/plant-challenge

CMD ["/usr/sbin/sshd", "-D", "-e"]
