FROM debian:bookworm

WORKDIR /opt

RUN apt update && apt install -y ncat gcc make

COPY Makefile start.sh main.c ./

# Create a new user that will run the vulnerable binary and set passwords
RUN useradd -m -s /bin/bash "user" && \
    echo "user:SomeRandomPassword" | chpasswd && \
    echo "root:SomeRandomPassword" | chpasswd


CMD ["./start.sh"]
