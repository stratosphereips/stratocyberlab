#!/bin/bash
set -eu
install -d -o root -g root -m 0755 /opt/lunar
cat > /opt/lunar/rotate.sh <<'EOF'
#!/bin/sh
printf '%s\n' 'Relay rotation queued.'
EOF
chown 10001:10001 /opt/lunar/rotate.sh
chmod 0755 /opt/lunar/rotate.sh
printf '%s\n' 'BSY{AZqkn6sSSBE3vRFRUk9bYXAhZdQQuAAK}' > /root/flag
printf '%s\n' 'escproof-5e599d8e722181a770f2edc1f2ee1115' > /root/.escalation-proof
chown root:root /root/flag /root/.escalation-proof
chmod 0400 /root/flag /root/.escalation-proof
