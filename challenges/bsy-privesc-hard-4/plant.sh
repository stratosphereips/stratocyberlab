#!/bin/bash
set -eu
useradd --create-home --shell /bin/bash forge
printf '%s:%s\n' forge 'NeonFoundry-6!Relay' | chpasswd
printf '%s\n' 'forge ALL=(root) NOPASSWD: /usr/bin/python3' > /etc/sudoers.d/forge-build-tools
chmod 0440 /etc/sudoers.d/forge-build-tools
printf '%s\n' 'BSY{TqMJmgFo2YUan1n4dg73hNJheSxLniEH}' > /root/flag
chown root:root /root/flag
chmod 0400 /root/flag
printf '%s\n' 'escproof-89c95b62e6ab8cec208d2c6e6ea0698a' > /root/.escalation-proof
chown root:root /root/.escalation-proof
chmod 0400 /root/.escalation-proof
