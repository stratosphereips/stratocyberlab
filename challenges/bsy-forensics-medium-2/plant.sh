#!/bin/sh
set -eu

printf 'root:orbital-archive-47\n' | chpasswd
for account in maint ops archivist; do
  useradd --create-home --shell /bin/bash "$account"
  printf '%s:%s\n' "$account" 'station-logbook-22' | chpasswd
done

mkdir -p /var/log /var/spool/cron/crontabs /usr/local/bin
cat > /usr/local/bin/station-audit <<'EOF'
#!/bin/sh
# Routine local housekeeping for the station archive.
printf '%s station-audit: archive index checked\n' "$(date -Is)" >> /var/log/station-audit.log
EOF
chmod 755 /usr/local/bin/station-audit

# A planted, inert cron entry: cron is not started in this forensic image.
cat > /var/spool/cron/crontabs/maint <<'EOF'
@daily /usr/local/bin/station-audit --quiet
@reboot /usr/local/sbin/telemetry-forwarder --session QlNZe1lxZFl6UmJ4MHFjR2Q2ZTZVeTdxMVFKZVhUbHFzS0VWfQ==
EOF
chown maint:crontab /var/spool/cron/crontabs/maint
chmod 600 /var/spool/cron/crontabs/maint

# Routine scheduled maintenance and corresponding log noise.
cat > /etc/cron.d/station-index <<'EOF'
12 * * * * root /usr/local/bin/station-audit --quiet
EOF
chmod 644 /etc/cron.d/station-index

cat > /var/log/auth.log <<'EOF'
May 18 01:05:12 station-jump sshd[811]: Accepted password for ops from 172.20.0.8 port 51120 ssh2
May 18 01:06:04 station-jump sudo: ops : TTY=pts/0 ; PWD=/home/ops ; USER=root ; COMMAND=/usr/bin/systemctl status ssh
May 18 01:08:17 station-jump sshd[811]: pam_unix(sshd:session): session closed for user ops
May 18 01:41:52 station-jump sshd[907]: Failed password for invalid user admin from 10.44.7.23 port 49201 ssh2
May 18 02:14:21 station-jump sshd[936]: Accepted password for maint from 10.44.7.23 port 49218 ssh2
May 18 02:16:09 station-jump sudo: maint : TTY=pts/1 ; PWD=/home/maint ; USER=root ; COMMAND=/usr/bin/crontab -e
May 18 02:18:33 station-jump sshd[936]: pam_unix(sshd:session): session closed for user maint
May 18 03:00:10 station-jump sshd[1012]: Accepted password for archivist from 172.20.0.8 port 51203 ssh2
May 18 03:03:41 station-jump sshd[1012]: pam_unix(sshd:session): session closed for user archivist
EOF

cat > /var/log/syslog <<'EOF'
May 18 00:12:00 station-jump CRON[701]: (root) CMD (/usr/local/bin/station-audit --quiet)
May 18 01:12:00 station-jump CRON[822]: (root) CMD (/usr/local/bin/station-audit --quiet)
May 18 02:12:00 station-jump CRON[918]: (root) CMD (/usr/local/bin/station-audit --quiet)
May 18 03:12:00 station-jump CRON[1034]: (root) CMD (/usr/local/bin/station-audit --quiet)
May 18 03:30:02 station-jump systemd[1]: systemd-tmpfiles-clean.service: Deactivated successfully.
EOF

cat > /home/maint/.bash_history <<'EOF'
cd /var/log
ls -lh
tail -n 20 auth.log
sudo crontab -l
sudo crontab -e
exit
EOF
cat > /home/ops/.bash_history <<'EOF'
systemctl status ssh
journalctl -u ssh --since today
exit
EOF
cat > /home/archivist/.bash_history <<'EOF'
find /srv/archive -type f -mtime +90 -print
ls -la /srv/archive
exit
EOF
chown maint:maint /home/maint/.bash_history
chown ops:ops /home/ops/.bash_history
chown archivist:archivist /home/archivist/.bash_history
chmod 600 /home/maint/.bash_history /home/ops/.bash_history /home/archivist/.bash_history

touch -d '2025-05-18 02:16:09 UTC' /var/spool/cron/crontabs/maint /home/maint/.bash_history
touch -d '2025-05-18 02:14:21 UTC' /var/log/auth.log
touch -d '2025-05-18 03:12:00 UTC' /var/log/syslog
