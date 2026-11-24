#!/bin/bash
set -euo pipefail

useradd --create-home --shell /bin/bash crew_ops
useradd --create-home --shell /bin/bash crew_sensor
useradd --create-home --shell /bin/bash crew_archive
useradd --create-home --shell /bin/bash svc_relaymon

printf '%s\n' 'root:relay-archive-42' | chpasswd

cat > /etc/ssh/sshd_config.d/99-challenge.conf <<'EOF'
PermitRootLogin yes
PasswordAuthentication yes
EOF

cat > /var/log/auth.log <<'EOF'
Mar 14 02:55:04 telemetry-relay sshd[810]: Accepted password for crew_ops from 172.20.0.12 port 50432 ssh2
Mar 14 02:55:04 telemetry-relay sshd[810]: pam_unix(sshd:session): session opened for user crew_ops(uid=1000) by (uid=0)
Mar 14 03:14:22 telemetry-relay sshd[944]: Accepted password for svc_relaymon from 172.20.0.3 port 41388 ssh2
Mar 14 03:14:22 telemetry-relay sshd[944]: pam_unix(sshd:session): session opened for user svc_relaymon(uid=1003) by (uid=0)
Mar 14 03:16:01 telemetry-relay sudo[967]: crew_ops : TTY=pts/0 ; PWD=/home/crew_ops ; USER=root ; COMMAND=/usr/bin/systemctl status ssh
Mar 14 03:21:48 telemetry-relay sshd[1002]: Failed password for invalid user admin from 192.0.2.44 port 58112 ssh2
Mar 14 04:02:10 telemetry-relay sshd[1091]: Accepted password for crew_archive from 172.20.0.18 port 50901 ssh2
Mar 14 04:02:10 telemetry-relay sshd[1091]: pam_unix(sshd:session): session opened for user crew_archive(uid=1002) by (uid=0)
EOF

cat > /var/log/syslog <<'EOF'
Mar 14 00:17:01 telemetry-relay CRON[701]: (root) CMD (cd / && run-parts --report /etc/cron.hourly)
Mar 14 01:17:01 telemetry-relay CRON[756]: (root) CMD (cd / && run-parts --report /etc/cron.hourly)
Mar 14 02:17:01 telemetry-relay CRON[799]: (root) CMD (cd / && run-parts --report /etc/cron.hourly)
Mar 14 03:17:01 telemetry-relay CRON[981]: (root) CMD (cd / && run-parts --report /etc/cron.hourly)
Mar 14 04:17:01 telemetry-relay CRON[1102]: (root) CMD (cd / && run-parts --report /etc/cron.hourly)
Mar 14 04:30:00 telemetry-relay systemd[1]: Started Daily apt download activities.
EOF

cat > /home/crew_sensor/.bash_history <<'EOF'
whoami
id
ls -la
find /var/lib/telemetry -maxdepth 1 -type f
exit
EOF
cat > /home/crew_ops/.bash_history <<'EOF'
sudo systemctl status ssh
journalctl -u ssh --since today
exit
EOF
cat > /home/crew_archive/.bash_history <<'EOF'
du -sh /srv/archive
tar -tf /srv/archive/latest.tar
exit
EOF
cat > /home/svc_relaymon/.bash_history <<'EOF'
whoami
id
uptime
exit
EOF
chown crew_sensor:crew_sensor /home/crew_sensor/.bash_history
chown crew_ops:crew_ops /home/crew_ops/.bash_history
chown crew_archive:crew_archive /home/crew_archive/.bash_history
chown svc_relaymon:svc_relaymon /home/svc_relaymon/.bash_history
chmod 0600 /home/crew_sensor/.bash_history /home/crew_ops/.bash_history /home/crew_archive/.bash_history /home/svc_relaymon/.bash_history

getent group crontab >/dev/null || groupadd crontab
install -d -o root -g crontab -m 1730 /var/spool/cron/crontabs

cat > /var/spool/cron/crontabs/crew_sensor <<'EOF'
# Local telemetry cache rotation
23 2 * * * /usr/bin/find /var/tmp/telemetry-cache -type f -mtime +7 -delete
EOF
chown crew_sensor:crontab /var/spool/cron/crontabs/crew_sensor
chmod 0600 /var/spool/cron/crontabs/crew_sensor

cat > /var/spool/cron/crontabs/crew_ops <<'EOF'
# Routine workstation cleanup
10 4 * * 0 /usr/bin/find /tmp -maxdepth 1 -type f -mtime +14 -delete
EOF
chown crew_ops:crontab /var/spool/cron/crontabs/crew_ops
chmod 0600 /var/spool/cron/crontabs/crew_ops

cat > /var/spool/cron/crontabs/crew_archive <<'EOF'
# Archive inventory reminder
35 1 * * * /usr/bin/find /srv/archive -maxdepth 1 -type f -name '*.tar' -print >/dev/null
EOF
chown crew_archive:crontab /var/spool/cron/crontabs/crew_archive
chmod 0600 /var/spool/cron/crontabs/crew_archive

cat > /var/spool/cron/crontabs/svc_relaymon <<'EOF'
# Relay maintenance entry
17 3 * * * /usr/bin/printf '%s' 'QlNZe01qd0htZkJBUHZHVEpzZUE5UEFPeWs5SlV3azk2VW5CfQ==' >/dev/null
EOF
chown svc_relaymon:crontab /var/spool/cron/crontabs/svc_relaymon
chmod 0600 /var/spool/cron/crontabs/svc_relaymon

install -d -m 0755 /etc/cron.d
cat > /etc/cron.d/relay-health <<'EOF'
# Routine relay health marker
*/15 * * * * root /usr/bin/test -d /var/lib/telemetry
EOF
chmod 0644 /etc/cron.d/relay-health

touch -d '2025-03-14 03:17:00 UTC' /var/log/auth.log /var/log/syslog
ssh-keygen -A
/usr/sbin/sshd -t
