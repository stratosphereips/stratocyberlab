FROM debian:bookworm

RUN apt update && apt install -y openssh-server gdb vim nano tmux curl python3 tshark gcc file

# install gef
RUN curl -fsSL https://gef.blah.cat/sh | bash

RUN mkdir -p /var/run/sshd
RUN mkdir -p /root/.ssh

COPY sshd_config /etc/ssh/sshd_config
COPY files /data/reversing-class

ENV TERM=xterm-256color
RUN echo "PS1='\e[92m\u\e[0m@\e[94m\h\e[0m:\e[35m\w\e[0m# '" >> /root/.bashrc && \
    echo "export LC_CTYPE=C.UTF-8" >> /root/.bashrc  # for gef

RUN echo "root:admin" | chpasswd

CMD ["/usr/sbin/sshd", "-D"]
