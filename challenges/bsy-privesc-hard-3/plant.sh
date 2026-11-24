#!/bin/bash
set -eu

printf '%s' "$FLAG" > /root/flag
chmod 0400 /root/flag
chown root:root /root/flag
printf '%s' "$CANARY" > /root/.escalation-proof
chmod 0400 /root/.escalation-proof
chown root:root /root/.escalation-proof

gcc -O2 -Wall -Wextra -o /usr/local/bin/clock-dispatch /tmp/dispatch.c
gcc -O2 -Wall -Wextra -o /usr/local/bin/ledger-check /tmp/ledger_check.c
chown root:root /usr/local/bin/clock-dispatch /usr/local/bin/ledger-check
chmod 4755 /usr/local/bin/clock-dispatch /usr/local/bin/ledger-check
