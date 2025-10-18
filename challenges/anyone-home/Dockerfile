FROM python:3.11-slim

ENV APP_HOME=/opt/anyone-home
WORKDIR ${APP_HOME}
ENV PYTHONUNBUFFERED=1

RUN apt update && apt install -y --no-install-recommends openssh-server \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

RUN mkdir -p /var/run/sshd
RUN mkdir -p /root/.ssh
COPY key.pub /root/.ssh/authorized_keys
COPY key /root/.ssh/key

RUN mkdir -p /var/www/payloads
COPY payload.sh /var/www/payloads/
COPY start.sh attacker.py ${APP_HOME}/

# Task 2 flag
RUN echo 'BSY{cQZ3TSoUVgbiO3EeyZiI5IidU6lcknWhjFRdeJppxV8yRs9M}' >> /root/.flag.txt
RUN echo "root:D4AIRdNguJa5" | chpasswd

CMD ["./start.sh"]
