FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server sudo cron netcat-openbsd ca-certificates && rm -rf /var/lib/apt/lists/*

COPY seed-host.sh /tmp/seed-host.sh
RUN bash /tmp/seed-host.sh && rm /tmp/seed-host.sh

EXPOSE 22
