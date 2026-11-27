#!/bin/bash
set -eu
printf '%s\n' 'BSY{tmi7Sg2lcLH2ja01hfBZl529MhGXXcvs}' > /root/flag
chmod 0400 /root/flag
chown root:root /root/flag
printf '%s\n' 'escproof-6a9394e2e650268d4f3aac42769fd39c' > /root/.escalation-proof
chmod 0400 /root/.escalation-proof
chown root:root /root/.escalation-proof
chmod u+s /usr/bin/find
