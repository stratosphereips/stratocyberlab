FROM python:3-slim

RUN apt update && apt install -y openssh-server ftp vim iproute2 net-tools tmux

RUN mkdir -p /var/run/sshd
RUN mkdir -p /root/.ssh

COPY sshd_config /etc/ssh/sshd_config

RUN echo "root:admin" | chpasswd

COPY start.sh server.py /

CMD ["./start.sh"]
