FROM ubuntu:24.04

RUN apt update && apt install -y --no-install-recommends openssh-server vim nano tmux bsdmainutils git less ca-certificates curl gnupg python3 python3-venv python3-pip && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd
RUN mkdir -p /root/.ssh

COPY sshd_config /etc/ssh/sshd_config
COPY files /data

RUN chmod +x /data/install-slips.sh

RUN /data/install-slips.sh

ENV TERM=xterm-256color
RUN echo "PS1='\[\e[92m\]\u\[\e[0m\]@\[\e[94m\]\h\[\e[0m\]:\[\e[35m\]\w\[\e[0m\]# '" >> /root/.bashrc && \
    echo "export LC_CTYPE=C.UTF-8" >> /root/.bashrc  && \
    echo 'export PATH=$PATH:/opt/zeek/bin' >> /root/.bashrc

RUN echo "root:admin" | chpasswd

CMD ["/usr/sbin/sshd", "-D"]
