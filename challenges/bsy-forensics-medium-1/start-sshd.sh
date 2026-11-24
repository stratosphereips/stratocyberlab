#!/bin/sh
set -eu
mkdir -p /run/sshd
ssh-keygen -A
cat > /etc/ssh/sshd_config <<'EOF'
Port 22
AddressFamily any
ListenAddress 0.0.0.0
PermitRootLogin yes
PasswordAuthentication yes
PubkeyAuthentication yes
UsePAM no
Subsystem sftp /usr/lib/openssh/sftp-server
EOF
/usr/sbin/sshd -t
exec /usr/sbin/sshd -D -e
