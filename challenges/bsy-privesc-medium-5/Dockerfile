FROM debian:bookworm
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends openssh-server sudo python3 gcc libc6-dev && rm -rf /var/lib/apt/lists/*
RUN if ! id gridops >/dev/null 2>&1; then useradd -m -s /bin/bash gridops; fi && usermod -s /bin/bash gridops && mkdir -p /home/gridops && chown gridops:gridops /home/gridops && echo 'gridops:orbit-7circuit' | chpasswd
RUN mkdir -p /run/sshd /opt/city-control /usr/local/bin
COPY wrapper.c /tmp/wrapper.c
COPY decoy.c /tmp/decoy.c
COPY plant.sh /tmp/plant.sh
RUN gcc -O2 -Wall -Wextra -o /usr/local/bin/metro-reconcile /tmp/wrapper.c && gcc -O2 -Wall -Wextra -o /usr/local/bin/diag-stamp /tmp/decoy.c && rm -f /tmp/wrapper.c /tmp/decoy.c && bash /tmp/plant.sh && rm -f /tmp/plant.sh && printf '%s\n' 'Port 22' 'PasswordAuthentication yes' 'KbdInteractiveAuthentication no' 'UsePAM no' 'PermitRootLogin no' 'AllowUsers gridops' 'Subsystem sftp /usr/lib/openssh/sftp-server' > /etc/ssh/sshd_config && ssh-keygen -A
WORKDIR /
CMD ["/usr/sbin/sshd", "-D", "-e"]
