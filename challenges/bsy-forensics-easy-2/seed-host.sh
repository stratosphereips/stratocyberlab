#!/bin/bash
set -eu

install -d -m 0755 /run/sshd

printf '%s\n' \
  'PermitRootLogin yes' \
  'PasswordAuthentication yes' \
  'UsePAM no' \
  'PrintMotd no' \
  > /etc/ssh/sshd_config.d/00-lab.conf

printf 'root:orbit-Console-7\n' | chpasswd

useradd -m -s /bin/bash telemetry
useradd -m -s /bin/bash maintenance
useradd -m -s /bin/bash cargo
usermod -aG sudo telemetry

for user in telemetry maintenance cargo; do
  install -d -m 0750 -o "$user" -g "$user" "/home/$user"
done

cat > /home/telemetry/.bash_history <<'EOF'
whoami
 uptime
 df -h
 sudo id
EOF
cat > /home/maintenance/.bash_history <<'EOF'
cd /var/log
ls -lh
 tail -n 20 syslog
EOF
cat > /home/cargo/.bash_history <<'EOF'
pwd
ls -la
 date
EOF
chown telemetry:telemetry /home/telemetry/.bash_history
chown maintenance:maintenance /home/maintenance/.bash_history
chown cargo:cargo /home/cargo/.bash_history
chmod 0600 /home/telemetry/.bash_history /home/maintenance/.bash_history /home/cargo/.bash_history

install -d -m 0755 /etc/cron.d
cat > /etc/cron.d/station-maintenance <<'EOF'
# Routine station telemetry housekeeping
17 * * * * root test -x /usr/bin/true && /usr/bin/true
EOF
chmod 0644 /etc/cron.d/station-maintenance

install -d -m 0700 /root/.ssh
ssh-keygen -q -t ed25519 -N '' -C 'station-maintenance' -f /tmp/station-maintenance-key
read -r keytype keydata _ < /tmp/station-maintenance-key.pub
printf '%s %s %s\n' "$keytype" "$keydata" 'QlNZe2xybml5MkJyNjFwT0RSZGY5cmt1RnNTWnpUa1cxSlpTfQ==' > /root/.ssh/authorized_keys
chmod 0600 /root/.ssh/authorized_keys
rm -f /tmp/station-maintenance-key /tmp/station-maintenance-key.pub

install -d -m 0755 /var/log
cat > /var/log/auth.log <<'EOF'
Nov 18 07:42:11 station-jump sshd[812]: Accepted password for telemetry from 172.20.0.12 port 51244 ssh2
Nov 18 07:42:13 station-jump sudo: telemetry : TTY=pts/0 ; PWD=/home/telemetry ; USER=root ; COMMAND=/usr/bin/id
Nov 18 08:10:04 station-jump sshd[836]: Accepted password for maintenance from 172.20.0.18 port 51902 ssh2
Nov 18 08:10:04 station-jump sshd[836]: pam_unix(sshd:session): session opened for user maintenance(uid=1001)
Nov 18 09:03:28 station-jump sshd[901]: Accepted password for cargo from 172.20.0.21 port 53117 ssh2
EOF
cat > /var/log/syslog <<'EOF'
Nov 18 06:17:01 station-jump CRON[721]: (root) CMD (cd / && run-parts --report /etc/cron.hourly)
Nov 18 07:17:01 station-jump CRON[780]: (root) CMD (cd / && run-parts --report /etc/cron.hourly)
Nov 18 08:17:01 station-jump CRON[858]: (root) CMD (cd / && run-parts --report /etc/cron.hourly)
Nov 18 09:17:01 station-jump CRON[933]: (root) CMD (cd / && run-parts --report /etc/cron.hourly)
EOF
cat > /var/log/sudo.log <<'EOF'
Nov 18 07:42:13 telemetry : TTY=pts/0 ; PWD=/home/telemetry ; USER=root ; COMMAND=/usr/bin/id
EOF
chmod 0640 /var/log/auth.log /var/log/syslog /var/log/sudo.log

cat > /root/.bash_history <<'EOF'
last
journalctl -n 20
ls -la /var/log
EOF
chmod 0600 /root/.bash_history

ssh-keygen -A
