#!/bin/bash
set -eu

useradd --create-home --shell /bin/bash frame
printf '%s:%s\n' 'frame' 'orbit-7delta' | chpasswd

install -o root -g root -m 0400 /dev/null /root/flag
printf '%s\n' 'BSY{ktZanwKktn8tlJcljL8c7kVjTzzvaPt6}' > /root/flag
chown root:root /root/flag
chmod 0400 /root/flag

install -o root -g root -m 0400 /dev/null /root/.escalation-proof
printf '%s\n' 'escproof-d0634dd2d0829c63299131adc86a35e0' > /root/.escalation-proof
chown root:root /root/.escalation-proof
chmod 0400 /root/.escalation-proof

chown root:root /usr/bin/find
chmod 4755 /usr/bin/find

ssh-keygen -A
chmod 0755 /run/sshd
