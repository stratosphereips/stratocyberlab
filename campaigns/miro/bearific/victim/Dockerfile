FROM debian:bookworm

RUN apt-get update &&\
    apt-get install -y openssh-server &&\
    mkdir /var/run/sshd &&\
    chmod 0755 /var/run/sshd &&\
    sed -i '$aPermitRootLogin yes' /etc/ssh/sshd_config &&\
    echo root:alpine | chpasswd

CMD /usr/sbin/sshd -D
