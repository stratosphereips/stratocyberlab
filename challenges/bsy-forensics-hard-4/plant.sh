#!/bin/sh
set -eu

# Ordinary build-team accounts with routine, inactive forensic noise.
for spec in "mira:Build operator" "forge:Release engineer" "buildbot:CI service account"; do
  name=${spec%%:*}
  gecos=${spec#*:}
  useradd --create-home --shell /bin/bash --comment "$gecos" "$name"
  passwd -l "$name" >/dev/null
  printf 'cd /srv/builds\nls -la\ngit status --short\n' > "/home/$name/.bash_history"
  chown "$name:$name" "/home/$name/.bash_history"
done

mkdir -p /srv/builds /var/log
printf '15 2 * * * /usr/bin/find /srv/builds -type f -mtime +14 -delete\n' | crontab -u mira -
printf '*/20 * * * * /usr/bin/logger -t build-heartbeat ok\n' | crontab -u buildbot -
printf '30 1 * * 0 /usr/bin/du -sh /srv/builds >/dev/null\n' | crontab -u forge -

# A conspicuous but inactive lead: this line is a comment, so cron never runs it.
cat > /etc/cron.d/telemetry-cache <<'EOF'
# Legacy relay note recovered from a maintenance ticket:
# @reboot root /usr/local/bin/relay-cache --upload --quiet
EOF
chmod 0644 /etc/cron.d/telemetry-cache

# Seed routine, non-sensitive system activity for timeline reconstruction.
cat > /var/log/auth.log <<'EOF'
Nov 20 08:12:04 neon-foundry-build sshd[410]: Accepted password for mira from 172.20.0.31 port 48110 ssh2
Nov 20 08:13:19 neon-foundry-build sudo: mira : TTY=pts/0 ; PWD=/srv/builds ; USER=root ; COMMAND=/usr/bin/systemctl status cron
Nov 20 09:44:51 neon-foundry-build sshd[522]: Failed password for invalid user deploy from 172.20.0.88 port 53309 ssh2
Nov 20 10:03:27 neon-foundry-build sshd[601]: Accepted password for forge from 172.20.0.32 port 48177 ssh2
Nov 20 10:04:02 neon-foundry-build sudo: forge : TTY=pts/1 ; PWD=/srv/builds ; USER=root ; COMMAND=/usr/bin/journalctl -n 20
Nov 20 10:20:00 neon-foundry-build CRON[711]: (buildbot) CMD (/usr/bin/logger -t build-heartbeat ok)
Nov 20 11:00:00 neon-foundry-build rsyslogd: log rotation completed
EOF
cat > /var/log/syslog <<'EOF'
Nov 20 08:00:00 neon-foundry-build systemd[1]: Started Daily apt download activities.
Nov 20 08:12:04 neon-foundry-build sshd[410]: Accepted password for mira from 172.20.0.31 port 48110 ssh2
Nov 20 10:03:27 neon-foundry-build sshd[601]: Accepted password for forge from 172.20.0.32 port 48177 ssh2
Nov 20 10:20:00 neon-foundry-build CRON[711]: (buildbot) CMD (/usr/bin/logger -t build-heartbeat ok)
Nov 20 11:00:00 neon-foundry-build logrotate[742]: rotated /var/log/auth.log
EOF

# A cleared history section is part of the compromised host's noisy timeline.
printf 'ls -la\ncd /srv/builds\ngit status --short\n' > /root/.bash_history

# Plant one altered packaged utility. The appended note is inert data; the
# executable code remains unchanged. Restore an old mtime to complicate review.
printf '\nSCL_NOTE_B64=QlNZe0xobGVuZVZQbDJaclVqQjM4ZXI2WEVRYnlBODFpQ0x1fQ==\n' >> /usr/bin/yes
touch -d '2021-04-07 03:12:00 UTC' /usr/bin/yes

chmod 0644 /var/log/auth.log /var/log/syslog
