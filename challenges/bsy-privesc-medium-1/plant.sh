#!/bin/bash
set -eu

useradd --create-home --shell /bin/bash buildbot
printf '%s:%s\n' 'buildbot' 'OrbitRelay-7q!' | chpasswd

# The login account has no sudo authorization.
printf '%s\n' 'buildbot ALL=(root) !ALL' > /etc/sudoers.d/buildbot
chmod 0440 /etc/sudoers.d/buildbot

# Seed the root-only flag and separate escalation proof.
printf '%s\n' 'BSY{Tb7mx20N4fyHrVXTA28jxXJafAhdSri1}' > /root/flag
chown root:root /root/flag
chmod 0400 /root/flag
printf '%s\n' 'escproof-23a781435c718944d36575d1abdb4561' > /root/.escalation-proof
chown root:root /root/.escalation-proof
chmod 0400 /root/.escalation-proof

# The build check is the escalation path; queue-status is a harmless decoy.
chown root:root /usr/local/bin/build-check /usr/local/bin/queue-status
chmod 4755 /usr/local/bin/build-check /usr/local/bin/queue-status

cat > /etc/ssh/sshd_config.d/challenge.conf <<'EOF'
PermitRootLogin no
PasswordAuthentication yes
UsePAM no
AllowUsers buildbot
EOF
