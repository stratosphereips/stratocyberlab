FROM debian:bookworm

COPY data /data

RUN apt update && \
    apt install -y openssh-server curl vim nano nmap net-tools iputils-ping htop netcat-traditional dnsutils \
    less tcpdump tmux wget iproute2 python3-pip git ncat rsyslog attr acl logcheck btop sshpass telnet python3-venv \
    proxychains binwalk

ENV TERM=xterm-256color
RUN echo "PS1='\e[92m\u\e[0m@\e[94m\h\e[0m:\e[35m\w\e[0m# '" >> /root/.bashrc

RUN mkdir -p /var/run/sshd
RUN mkdir -p /root/.ssh

COPY config/sshd_config /etc/ssh/sshd_config
COPY config/banner /etc/banner
COPY tools/tcpdump-colorize.pl /usr/bin/tcpdump-colorize.pl
COPY start.sh /root/.start-container.sh

# 1. Init utmp logging (for "w" command)
# 2. Disable kernel logging for syslog (not supported in container environment)
# 3. Set locale lang to avoid errors in auth.log
# 4. Disable systemd in PAM because systemd is not running in the container
# 5. Set readenv attribute to false to avoid deprecated warnings in auth.log
RUN touch /var/run/utmp && \
    sed -i '/imklog/ s/^/#/' /etc/rsyslog.conf && \
    echo "LANG=en_US.UTF-8" > /etc/default/locale && \
    sed -i '/pam_systemd.so/ s/^/#/' /etc/pam.d/common-session && \
    sed -i 's/user_readenv=1/user_readenv=0/' /etc/pam.d/sshd


# easy flag for a hello world challenge
RUN echo "BSY{6JmUwlxDMqAi7LGKyDifntSZuFCku7KaTbnYxkSvziYBLg4AwCjubDeBQHxE}" > ~/.flag.txt

RUN echo "root:ByteThem123" | chpasswd

CMD ["/root/.start-container.sh"]