#!/bin/bash
set -eu
printf '%s\n' 'BSY{SYBbRNrdVbsHbhE9nQYAzoAyagItPULS}' > /root/flag
chown root:root /root/flag
chmod 0400 /root/flag
printf '%s\n' 'escproof-e11b809d7326832da0adc894182fd1e8' > /root/.escalation-proof
chown root:root /root/.escalation-proof
chmod 0400 /root/.escalation-proof
cat > /opt/city-control/reconcile.py <<'PY'
print('City control reconciliation complete.')
PY
chown -R gridops:gridops /opt/city-control
chmod 0755 /opt/city-control
chmod 0644 /opt/city-control/reconcile.py
chown root:root /usr/local/bin/metro-reconcile /usr/local/bin/diag-stamp
chmod 4755 /usr/local/bin/metro-reconcile /usr/local/bin/diag-stamp
