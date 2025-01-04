FROM debian:bookworm

RUN <<EOF
apt-get update
apt-get install -y inetutils-ping iproute2 curl
EOF

WORKDIR /app
COPY init.sh /app
CMD bash init.sh
