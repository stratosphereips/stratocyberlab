#!/bin/bash
set -euo pipefail

install -d -m 0755 /run/sshd
printf '%s\n' 'BSY{cKiythtrsTH3uswExCVJBN1oN9qBSpQb}' > /root/flag
chown root:root /root/flag
chmod 0400 /root/flag
printf '%s\n' 'escproof-4b47c766f743a529739f1a6aae9c982d' > /root/.escalation-proof
chown root:root /root/.escalation-proof
chmod 0400 /root/.escalation-proof

# Remove inherited setuid/setgid bits so the planted footholds are easy to distinguish.
find / -xdev -type f -perm /6000 -exec chmod a-s {} +

gcc -O2 -Wall -Wextra -o /usr/local/bin/clockstamp /opt/challenge/clockstamp.c
chown root:root /usr/local/bin/clockstamp
chmod 4755 /usr/local/bin/clockstamp

python_real="$(readlink -f /usr/bin/python3)"
setcap cap_setuid+ep "$python_real"
