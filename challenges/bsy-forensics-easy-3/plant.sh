#!/bin/bash
set -euo pipefail

useradd --create-home --shell /bin/bash buildbot
useradd --create-home --shell /bin/bash deploy
printf 'buildbot:runner-only\n' | chpasswd
printf 'deploy:runner-only\n' | chpasswd

mkdir -p /var/log /var/tmp /home/buildbot /home/deploy
cat > /home/buildbot/.bash_history <<'EOF'
cd /srv/ci
ls -la
./build.sh
exit
EOF
cat > /home/deploy/.bash_history <<'EOF'
systemctl status ssh
sudo id
journalctl -n 20
exit
EOF
cat > /root/.bash_history <<'EOF'
apt-get update
systemctl status cron
ls -la /srv/ci
EOF
chown buildbot:buildbot /home/buildbot/.bash_history
chown deploy:deploy /home/deploy/.bash_history
chmod 600 /home/buildbot/.bash_history /home/deploy/.bash_history /root/.bash_history

cat > /etc/cron.d/runner-maintenance <<'EOF'
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
17 4 * * * root test -d /srv/ci && /usr/bin/find /srv/ci -type f -name '*.tmp' -mtime +7 -delete
EOF
chmod 644 /etc/cron.d/runner-maintenance

cat > /var/log/auth.log <<'EOF'
Nov 22 08:14:03 neon-runner sshd[611]: Accepted password for buildbot from 172.20.0.21 port 52144 ssh2
Nov 22 08:14:07 neon-runner sshd[611]: pam_unix(sshd:session): session opened for user buildbot(uid=1000)
Nov 22 08:18:40 neon-runner sshd[611]: pam_unix(sshd:session): session closed for user buildbot
Nov 22 09:02:11 neon-runner sudo: deploy : TTY=pts/0 ; PWD=/home/deploy ; USER=root ; COMMAND=/usr/bin/id
Nov 22 09:02:12 neon-runner sudo: pam_unix(sudo:session): session closed for user root
Nov 22 09:40:01 neon-runner CRON[812]: pam_unix(cron:session): session opened for user root(uid=0)
Nov 22 09:40:01 neon-runner CRON[812]: pam_unix(cron:session): session closed for user root
EOF
cat > /var/log/syslog <<'EOF'
Nov 22 04:17:01 neon-runner CRON[414]: (root) CMD (test -d /srv/ci && /usr/bin/find /srv/ci -type f -name '*.tmp' -mtime +7 -delete)
Nov 22 08:14:03 neon-runner sshd[611]: Server listening on 0.0.0.0 port 22.
Nov 22 09:02:11 neon-runner sudo: deploy : COMMAND=/usr/bin/id
Nov 22 09:40:01 neon-runner CRON[812]: (root) CMD (run-parts --report /etc/cron.hourly)
EOF
chmod 640 /var/log/auth.log /var/log/syslog

printf 'runner cache warmup complete\n' > /var/tmp/runner-warmup.txt
chmod 644 /var/tmp/runner-warmup.txt

# The lone planted intrusion artifact: inert staged data, never executed.
printf '%s' 'QlNZe3JQSmRuck53SjVCdW42YWdwZFdwa1ZHTzNTY3ZsaXpqfQ==' > /var/tmp/.runner-telemetry
chown root:root /var/tmp/.runner-telemetry
chmod 600 /var/tmp/.runner-telemetry
touch -d '2026-11-23 02:13:00 UTC' /var/tmp/.runner-telemetry
touch -d '2026-11-20 11:30:00 UTC' /var/tmp/runner-warmup.txt
