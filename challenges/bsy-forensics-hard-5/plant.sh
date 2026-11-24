#!/bin/bash
set -eu

echo 'root:OrbitGlass-44' | chpasswd
useradd -m -s /bin/bash analyst
useradd -m -s /bin/bash builder
useradd -m -s /bin/bash deploy
for spec in 'analyst:ReadOnly-17' 'builder:Compile-28' 'deploy:Release-31'; do
  echo "$spec" | chpasswd
done
usermod -aG sudo analyst

cat >/etc/ssh/sshd_config <<'EOF'
Port 22
AddressFamily any
ListenAddress 0.0.0.0
PermitRootLogin yes
PasswordAuthentication yes
KbdInteractiveAuthentication no
UsePAM no
X11Forwarding no
PrintMotd no
Subsystem sftp /usr/lib/openssh/sftp-server
EOF

mkdir -p /run/sshd /var/log /etc/cron.d
: >/var/log/auth.log
: >/var/log/syslog
chmod 0640 /var/log/auth.log /var/log/syslog

cat >/etc/cron.d/build-maintenance <<'EOF'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
17 3 * * 0 root /usr/bin/find /var/tmp/build-cache -type f -mtime +14 -delete
EOF
chmod 0644 /etc/cron.d/build-maintenance
mkdir -p /var/tmp/build-cache /home/builder/bin /home/deploy/bin
cat >/home/builder/.bash_history <<'EOF'
cd /srv/atlas
make clean
make package
sudo systemctl status cron
EOF
cat >/home/deploy/.bash_history <<'EOF'
cd /srv/atlas
sha256sum release.tar
sudo journalctl -n 20
EOF
cat >/root/.bash_history <<'EOF'
useradd -m builder
useradd -m deploy
install -m 0644 /etc/cron.d/build-maintenance /etc/cron.d/build-maintenance
# older session entries unavailable after terminal rotation
EOF
chown builder:builder /home/builder/.bash_history
chown deploy:deploy /home/deploy/.bash_history
chmod 0600 /home/builder/.bash_history /home/deploy/.bash_history /root/.bash_history

cat >/etc/cron.d/telemetry-repair <<'EOF'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
# * * * * * root /usr/local/sbin/.telemetry-repair --sync
EOF
chmod 0644 /etc/cron.d/telemetry-repair
mkdir -p /usr/local/sbin
cat >/usr/local/sbin/.telemetry-repair <<'EOF'
#!/bin/sh
# Retired build telemetry stub; intentionally inert.
exit 0
EOF
chmod 0755 /usr/local/sbin/.telemetry-repair
cat >>/var/log/syslog <<'EOF'
Nov  5 02:17:01 build-orbit-7 CRON[812]: (root) CMD (find /var/tmp/build-cache -type f -mtime +14 -delete)
Nov  5 02:17:02 build-orbit-7 CRON[813]: parser skipped commented telemetry-repair schedule
Nov  5 02:18:11 build-orbit-7 buildd[920]: package atlas-agent completed
EOF
cat >>/var/log/auth.log <<'EOF'
Nov  5 08:44:02 build-orbit-7 sshd[1201]: Accepted password for builder from 172.20.0.21 port 43110 ssh2
Nov  5 08:44:05 build-orbit-7 sudo: builder : TTY=pts/0 ; PWD=/srv/atlas ; USER=root ; COMMAND=/usr/bin/systemctl status cron
Nov  5 09:12:33 build-orbit-7 sshd[1244]: Accepted password for deploy from 172.20.0.22 port 43201 ssh2
EOF

install -d -m 0700 -o builder -g builder /home/builder/.ssh
ssh-keygen -q -t ed25519 -N '' -C temporary-build-key -f /tmp/temporary-build-key
KEY_BODY=$(awk '{print $2}' /tmp/temporary-build-key.pub)
printf 'ssh-ed25519 %s audit-token:QlNZe3pyb0VDTjFvcjFXT1kxaTNHZDcxZ2dwdnlvNVRaYjBHfQ==\n' "$KEY_BODY" >/home/builder/.ssh/authorized_keys
chown builder:builder /home/builder/.ssh/authorized_keys
chmod 0600 /home/builder/.ssh/authorized_keys
touch -d '2021-04-19 03:11:00 UTC' /home/builder/.ssh/authorized_keys
rm -f /tmp/temporary-build-key /tmp/temporary-build-key.pub
touch /etc/cron.d/telemetry-repair /usr/local/sbin/.telemetry-repair
