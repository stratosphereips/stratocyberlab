FROM debian:12 AS gobuilder

RUN apt update && apt install -y openssh-server tmux vim nano curl ncat jq iputils-ping iproute2 python3 python3-venv

RUN bash -c "cd ~ && python3 -m venv cai_env && source cai_env/bin/activate && pip install cai-framework"

RUN mkdir -p /var/run/sshd /root/.ssh
COPY sshd_config /etc/ssh/sshd_config

ENV TERM=xterm-256color
RUN echo "PS1='\[\e[92m\]\u\[\e[0m\]@\[\e[94m\]\h\[\e[0m\]:\[\e[35m\]\w\[\e[0m\]# '" >> /root/.bashrc && \
    echo "export LC_CTYPE=C.UTF-8" >> /root/.bashrc

RUN echo "root:admin" | chpasswd

COPY files /data

CMD ["/usr/sbin/sshd", "-D"]
