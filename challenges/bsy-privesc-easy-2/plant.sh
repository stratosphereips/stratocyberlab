#!/bin/bash
set -eu

printf '%s\n' 'BSY{tnuopbo8WsxjjNIOvMZuEzTjahfyktjt}' > /root/flag
chmod 0400 /root/flag
chown root:root /root/flag

printf '%s\n' 'escproof-0325e9c12901b435fcff6e21ee4d55a2' > /root/.escalation-proof
chmod 0400 /root/.escalation-proof
chown root:root /root/.escalation-proof

setcap cap_setuid+ep /usr/bin/python3.11
