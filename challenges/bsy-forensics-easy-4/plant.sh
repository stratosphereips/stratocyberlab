#!/bin/sh
set -eu

useradd -m -s /bin/bash -c 'Night shift console operator' frameops59
useradd -m -s /bin/bash -c 'Archive index maintainer' archive59
useradd -m -s /bin/bash -c 'Telemetry relay technician' telemetry59
useradd -m -s /bin/bash -c 'QlNZezZpSGt1emlEVmhJM005UGMxcllqbU1USHIwbndFMG9EfQ==' svc-frame-rebuild

printf '%s\n' \
  '# Routine archive rotation' \
  '17 2 * * 0 root /usr/bin/find /var/log -type f -name "*.old" -delete' \
  > /etc/cron.d/archive-rotation
chmod 0644 /etc/cron.d/archive-rotation

printf '%s\n' \
  'Nov 21 01:17:04 frame-gateway CRON[318]: (root) CMD (/usr/bin/find /var/log -type f -name "*.old" -delete)' \
  'Nov 21 08:02:11 frame-gateway sshd[941]: Accepted password for root from 172.20.0.3 port 42218 ssh2' \
  'Nov 21 08:06:43 frame-gateway sudo: frameops59 : TTY=pts/0 ; PWD=/home/frameops59 ; USER=root ; COMMAND=/usr/bin/systemctl status cron' \
  > /var/log/auth.log

printf '%s\n' \
  'Nov 21 01:17:04 frame-gateway CRON[318]: (root) CMD (/usr/bin/find /var/log -type f -name "*.old" -delete)' \
  'Nov 21 08:06:43 frame-gateway systemd[1]: cron.service: status queried by frameops59' \
  > /var/log/syslog

printf '%s\n' \
  'ls -la /var/log' \
  'sudo systemctl status cron' \
  'tail -n 20 /var/log/syslog' \
  > /home/frameops59/.bash_history
chown frameops59:frameops59 /home/frameops59/.bash_history

printf '%s\n' \
  'grep -R archive /etc/cron.d' \
  'date -u' \
  > /home/archive59/.bash_history
chown archive59:archive59 /home/archive59/.bash_history

printf '%s\n' \
  'uptime' \
  'sudo -l' \
  > /home/telemetry59/.bash_history
chown telemetry59:telemetry59 /home/telemetry59/.bash_history

touch -d '2026-11-20 02:00:00 UTC' /etc/cron.d/archive-rotation
touch -d '2026-11-21 08:06:43 UTC' /var/log/auth.log /var/log/syslog
