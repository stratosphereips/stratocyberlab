#!/bin/bash
set -eu

useradd --create-home --shell /bin/bash retro
printf '%s:%s\n' retro 'orbit-terminal-6' | chpasswd

install -d -m 0755 /run/sshd
sed -ri 's/^#?PermitRootLogin.*/PermitRootLogin no/; s/^#?PasswordAuthentication.*/PasswordAuthentication yes/; s/^#?UsePAM.*/UsePAM no/' /etc/ssh/sshd_config
printf '\nKbdInteractiveAuthentication no\nAllowUsers retro\n' >> /etc/ssh/sshd_config

cat > /root/flag <<'EOF'
BSY{Mm3VTmVkd5nszF18oU2dPPscEnl8U20e}
EOF
chown root:root /root/flag
chmod 0400 /root/flag
cat > /root/.escalation-proof <<'EOF'
escproof-1683b5e7e0a4b7d9b34cfced31307175
EOF
chown root:root /root/.escalation-proof
chmod 0400 /root/.escalation-proof

chown root:root /usr/bin/find
chmod 4755 /usr/bin/find

chown root:root /usr/bin/true /usr/bin/false
chmod 4755 /usr/bin/true /usr/bin/false
