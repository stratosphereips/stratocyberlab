FROM debian:bookworm

RUN apt update && apt install -y openssh-server curl

RUN mkdir -p /var/run/sshd
RUN mkdir -p /root/.ssh

RUN useradd -m -s /bin/bash admin && \
  echo "admin:super-secret-password-cannot-be-guessed" | chpasswd && \
  echo "BSY{THd8a6l0GCoRDpRThK9z1FnoEcl0y0cV8CTUGNBWwXHXAC5XDyNVqIP5mDHH}" > /home/admin/flag.txt && \
  chmod 777 /home/admin/flag.txt

COPY sshd_config /etc/ssh/sshd_config
COPY keep-connecting.sh /opt/keep-connecting.sh

CMD ["/opt/keep-connecting.sh"]
