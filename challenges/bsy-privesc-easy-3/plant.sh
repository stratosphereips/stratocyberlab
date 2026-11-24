#!/bin/bash
set -eu
printf '%s\n' 'BSY{6K4zII2T8x94QLs96aUSKRkQH4Pyt1MV}' > /root/flag
chown root:root /root/flag
chmod 0400 /root/flag
printf '%s\n' 'escproof-4b07ad360fe280eaef0d707ad6c25ded' > /root/.escalation-proof
chown root:root /root/.escalation-proof
chmod 0400 /root/.escalation-proof
printf '%s\n' 'cityops ALL=(root) NOPASSWD: /usr/bin/find' > /etc/sudoers.d/cityops
chmod 0440 /etc/sudoers.d/cityops
visudo -cf /etc/sudoers.d/cityops
