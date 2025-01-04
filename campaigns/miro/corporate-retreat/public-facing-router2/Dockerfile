FROM debian:bookworm

RUN <<EOF
apt-get update
apt-get install -y iptables
EOF

WORKDIR /app
COPY init.sh /app

CMD bash init.sh
