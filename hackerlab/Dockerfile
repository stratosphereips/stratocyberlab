FROM debian:bookworm

RUN apt update && \
    apt install -y openssh-server curl vim nano nmap

RUN mkdir -p /var/run/sshd
RUN mkdir -p /root/.ssh

COPY config/sshd_config /etc/ssh/sshd_config
COPY config/banner /etc/banner

RUN echo "root:ByteThem123" | chpasswd

CMD ["/usr/sbin/sshd", "-D"]