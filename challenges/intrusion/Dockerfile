FROM debian:bookworm

# Set non-interactive frontend for apt-get
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    auditd \
    vim \
    wget \
    attr \
    less \
    python3 \
    libcap2-bin \
    grep \
    cron \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd

# Create multiple users
RUN useradd -ms /bin/bash alice && echo 'alice:password' | chpasswd && usermod -aG sudo alice
RUN useradd -ms /bin/bash bob && echo 'bob:password' | chpasswd
RUN useradd -ms /bin/bash charlie && echo 'charlie:password' | chpasswd

# Set root password
RUN echo 'root:i_am_administrator' | chpasswd

# Configure SSH to allow root login and password authentication
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Run attacker actions
COPY attack.sh /attack.sh
RUN /attack.sh && rm /attack.sh

CMD ["/usr/sbin/sshd", "-D"]