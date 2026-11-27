#!/bin/bash
set -eu

useradd --create-home --shell /bin/bash deckhand
echo 'deckhand:orbital-wrench-61' | chpasswd

install -d -m 0755 /etc/ssh/sshd_config.d
cat > /etc/ssh/sshd_config.d/99-maintenance-console.conf <<'EOF'
PasswordAuthentication yes
PermitRootLogin no
AllowUsers deckhand
EOF

printf '%s\n' 'BSY{ZQQumd8dhyD4yhNcsF45bDStB6dFquOe}' > /root/flag
chown root:root /root/flag
chmod 0400 /root/flag

printf '%s\n' 'escproof-32acbe1fb416761dfcc8d77a40bb2788' > /root/.escalation-proof
chown root:root /root/.escalation-proof
chmod 0400 /root/.escalation-proof

chmod u+s /usr/bin/find
install -o root -g root -m 4755 /usr/bin/true /usr/local/bin/diag-selftest
