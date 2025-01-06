FROM debian:bookworm

RUN <<EOF
apt-get update
apt-get install -y iptables ulogd2
EOF

COPY ssh.log /var/log/ulog/syslogemu.log

WORKDIR /app
COPY init.sh /app
CMD bash init.sh
