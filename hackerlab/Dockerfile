FROM debian:bookworm

RUN apt update && \
    apt install -y openssh-server curl vim nano nmap

ENV TERM=xterm-256color
RUN echo "PS1='\e[92m\u\e[0m@\e[94m\h\e[0m:\e[35m\w\e[0m# '" >> /root/.bashrc

RUN mkdir -p /var/run/sshd
RUN mkdir -p /root/.ssh

COPY config/sshd_config /etc/ssh/sshd_config
COPY config/banner /etc/banner

RUN echo "root:ByteThem123" | chpasswd

CMD ["/usr/sbin/sshd", "-D"]