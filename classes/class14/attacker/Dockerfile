FROM debian:bookworm

RUN apt update && \
    apt install -y openssh-server

RUN mkdir -p /var/run/sshd
RUN mkdir -p /root/.ssh

COPY sshd_config /etc/ssh/sshd_config

RUN echo "root:admin" | chpasswd

CMD ["/usr/sbin/sshd", "-D"]
