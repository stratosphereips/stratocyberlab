FROM debian:bookworm

COPY data /data

RUN apt update && \
    apt install -y openssh-server curl vim nano nmap net-tools iputils-ping htop netcat-traditional dnsutils less tcpdump tmux wget iproute2 python3-pip git ncat

ENV TERM=xterm-256color
RUN echo "PS1='\e[92m\u\e[0m@\e[94m\h\e[0m:\e[35m\w\e[0m# '" >> /root/.bashrc

RUN mkdir -p /var/run/sshd
RUN mkdir -p /root/.ssh

COPY config/sshd_config /etc/ssh/sshd_config
COPY config/banner /etc/banner
COPY tools/tcpdump-colorize.pl /usr/bin/tcpdump-colorize.pl

# easy flag for a hello world challenge
RUN echo "BSY{6JmUwlxDMqAi7LGKyDifntSZuFCku7KaTbnYxkSvziYBLg4AwCjubDeBQHxE}" > ~/.flag.txt

RUN echo "root:ByteThem123" | chpasswd

CMD ["/usr/sbin/sshd", "-D"]