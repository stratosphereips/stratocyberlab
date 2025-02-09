FROM alpine:3.20.3

RUN apk add python3 py3-pip &&\
    pip install netmiko --break-system-packages &&\
    mkdir /app

COPY bearific-ssh-attacker.py /app
COPY runner.sh /app

WORKDIR /app

CMD sh runner.sh
