FROM debian:12 AS gobuilder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential

RUN ARCH=$(dpkg --print-architecture) && \
    case "$ARCH" in \
      amd64) GOARCH=amd64 ;; \
      arm64) GOARCH=arm64 ;; \
      *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac && \
    wget https://go.dev/dl/go1.23.3.linux-${GOARCH}.tar.gz && \
    tar -C /usr/local -xzf go1.23.3.linux-${GOARCH}.tar.gz && \
    rm go1.23.3.linux-${GOARCH}.tar.gz

# Set Go environment
ENV PATH="/usr/local/go/bin:$PATH"
ENV GOPATH="/root/go"
ENV PATH="$GOPATH/bin:$PATH"

# Install assetfinder
RUN go install github.com/tomnomnom/assetfinder@latest

# Install gobuster
RUN go install github.com/OJ/gobuster/v3@latest

# gau
RUN go install -v github.com/lc/gau/v2/cmd/gau@latest



FROM debian:12 AS base

RUN dpkg --add-architecture amd64 && apt update -y && apt upgrade -y

RUN apt-get install -y \
        make \
        build-essential \
        libssl-dev \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        wget \
        curl \
        llvm \
        git \
        ca-certificates \
        unzip \
        nano \
        net-tools \
        knot-dnsutils \
        dnsutils \
        jq

# Install Pyenv
ENV PYENV_ROOT=/usr/local/pyenv
ENV PATH="$PYENV_ROOT/bin:$PATH"

RUN git clone https://github.com/pyenv/pyenv.git /usr/local/pyenv && \
	eval "$(pyenv init --path)" && \
	pyenv install $(pyenv install -l | grep -v - | grep -E '^  3\.[0-9]+\.[0-9]+$' | tail -1) && \
	pyenv global $(pyenv install -l | grep -v - | grep -E '^  3\.[0-9]+\.[0-9]+$' | tail -1)



FROM base AS pybuilder

RUN wget https://github.com/sqlmapproject/sqlmap/archive/refs/heads/master.zip -O /tmp/sqlmap.zip && \
	unzip /tmp/sqlmap.zip -d /tmp/ && \
	mv /tmp/sqlmap-master /opt/sqlmap


FROM base AS wordlists

RUN mkdir -p /data/wordlist && \
    wget -O /data/wordlist/directories.txt \
    https://raw.githubusercontent.com/danielmiessler/SecLists/refs/heads/master/Discovery/Web-Content/DirBuster-2007_directory-list-2.3-big.txt

# Final image
FROM base AS runtime

# /----------- common part with SSH installation
RUN apt update && apt install -y openssh-server

RUN mkdir -p /var/run/sshd && mkdir -p /root/.ssh

COPY sshd_config /etc/ssh/sshd_config
COPY files /data

ENV TERM=xterm-256color
RUN echo "PS1='\[\e[92m\]\u\[\e[0m\]@\[\e[94m\]\h\[\e[0m\]:\[\e[35m\]\w\[\e[0m\]# '" >> /root/.bashrc && \
    echo "export LC_CTYPE=C.UTF-8" >> /root/.bashrc  && \
    echo 'export PATH=$PATH:/opt/zeek/bin' >> /root/.bashrc

RUN echo "root:admin" | chpasswd

CMD ["/usr/sbin/sshd", "-D"]
# \----------- common part with SSH installation

# Copy tools from builder
COPY --from=gobuilder /root/go/bin/assetfinder /usr/local/bin/
COPY --from=gobuilder /root/go/bin/gobuster /usr/local/bin/
COPY --from=gobuilder /root/go/bin/gau /usr/local/bin/
COPY --from=gobuilder /usr/local/go /usr/local/go

# Copy Pyenv
COPY --from=pybuilder /usr/local/pyenv /usr/local/pyenv
COPY --from=pybuilder /opt/sqlmap /opt/sqlmap
RUN ln -s /opt/sqlmap/sqlmap.py /usr/local/bin/sqlmap

# Copy wordlists
COPY --from=wordlists /data/wordlist /data/wordlist

# Set environment variables
ENV PYENV_ROOT="/usr/local/pyenv"
ENV GOPATH="/root/go"
ENV PATH="/usr/local/go/bin:$GOPATH/bin:$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"

# we need to write this to bashrc so that ssh will set same env variables
RUN echo 'export PYENV_ROOT="/usr/local/pyenv"' >> /root/.bashrc && \
    echo 'export GOPATH="/root/go"' >> /root/.bashrc && \
    echo 'export PATH="/usr/local/go/bin:$GOPATH/bin:$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"' >> /root/.bashrc

# Verify installations
RUN go version && \
    pyenv versions && \
    assetfinder -h && \
    gobuster version && \
    sqlmap --version && \
    gau -h

