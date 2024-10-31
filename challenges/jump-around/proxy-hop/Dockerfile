FROM debian:bookworm

RUN apt update && apt install -y openssh-server dante-server tcpdump vim wget

RUN mkdir -p /var/run/sshd
RUN mkdir -p /root/.ssh

RUN useradd -m -s /bin/bash bob && \
  echo "bob:iloveyoumandy" | chpasswd && \
  chmod +s $(which find) && \
  echo "BSY{QQgCzB3HmryOC7aijBJfeylUYOzgMviOIkdBzlMmGYgJWoY4Sz21s3ZcIPiW}" > /root/flag.txt

COPY sshd_config /etc/ssh/sshd_config
COPY danted.conf /etc/danted.conf
COPY start.sh /opt/start.sh

CMD ["/opt/start.sh"]
