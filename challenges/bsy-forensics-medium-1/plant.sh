#!/bin/sh
set -eu

printf '%s\n' 'root:scl-root-ember-42' | chpasswd
useradd --create-home --shell /bin/bash buildbot
useradd --create-home --shell /bin/bash deploy
useradd --create-home --shell /bin/bash qa

install -d -m 0700 -o buildbot -g buildbot /home/buildbot/.ssh
install -d -m 0700 -o deploy -g deploy /home/deploy/.ssh
install -d -m 0755 /var/cache/forge/buildbot /srv/forge/reports

# Ordinary automation credential for background noise.
ssh-keygen -q -t ed25519 -N '' -C 'ci-deploy@forge-07' -f /tmp/deploy-ci-key
install -m 0600 -o deploy -g deploy /tmp/deploy-ci-key.pub /home/deploy/.ssh/authorized_keys
rm -f /tmp/deploy-ci-key /tmp/deploy-ci-key.pub

# The planted key is inert; its private half is discarded.
ssh-keygen -q -t ed25519 -N '' -C 'QlNZezlmSnA1aEhYYjFGT0ZBdTNDckx3cGhoOVBqSnVIcnphfQ==' -f /tmp/planted-key
install -m 0600 -o buildbot -g buildbot /tmp/planted-key.pub /home/buildbot/.ssh/authorized_keys
PLANTED_FP=$(ssh-keygen -lf /tmp/planted-key.pub | awk '{print $2}')
rm -f /tmp/planted-key /tmp/planted-key.pub

cat > /home/buildbot/.bash_history <<'EOF'
cd /srv/forge
ls -la
make clean
make release
sudo systemctl status forge-agent
journalctl -u forge-agent --since yesterday
EOF
cat > /home/deploy/.bash_history <<'EOF'
cd /srv/forge
ls artifacts
sha256sum release.tar
sudo systemctl status ssh
EOF
cat > /home/qa/.bash_history <<'EOF'
cd /srv/forge/reports
ls -lt
python3 summarize.py
EOF
chown buildbot:buildbot /home/buildbot/.bash_history
chown deploy:deploy /home/deploy/.bash_history
chown qa:qa /home/qa/.bash_history
chmod 0600 /home/buildbot/.bash_history /home/deploy/.bash_history /home/qa/.bash_history

cat > /etc/cron.d/forge-cache <<'EOF'
# Routine build cache housekeeping
17 2 * * * buildbot /usr/bin/find /var/cache/forge/buildbot -type f -mtime +7 -delete
EOF
cat > /etc/cron.d/forge-reports <<'EOF'
# Weekly report bundle maintenance
30 4 * * 1 qa /usr/bin/find /srv/forge/reports -type f -mtime +30 -delete
EOF
chmod 0644 /etc/cron.d/forge-cache /etc/cron.d/forge-reports

cat > /var/log/auth.log <<EOF
Mar 14 01:02:11 forge-07 sshd[1201]: Accepted publickey for deploy from 172.20.0.21 port 42118 ssh2: ED25519 SHA256:6BmPq7b2oFb2XH7Qz1QYx0q7B6nS0m7pWcHhP0gLJ8A
Mar 14 01:02:11 forge-07 sshd[1201]: pam_unix(sshd:session): session opened for user deploy(uid=1001) by (uid=0)
Mar 14 01:08:45 forge-07 sudo: deploy : TTY=pts/0 ; PWD=/srv/forge ; USER=root ; COMMAND=/usr/bin/systemctl status forge-agent
Mar 14 02:51:03 forge-07 sshd[1630]: Failed password for root from 172.20.0.88 port 51302 ssh2
Mar 14 02:51:09 forge-07 sshd[1630]: Failed password for root from 172.20.0.88 port 51302 ssh2
Mar 14 02:51:15 forge-07 sshd[1630]: Failed password for root from 172.20.0.88 port 51302 ssh2
Mar 14 03:17:42 forge-07 sshd[1842]: Accepted publickey for buildbot from 172.20.0.73 port 51842 ssh2: ED25519 ${PLANTED_FP}
Mar 14 03:17:42 forge-07 sshd[1842]: pam_unix(sshd:session): session opened for user buildbot(uid=1000) by (uid=0)
Mar 14 03:19:06 forge-07 sshd[1842]: pam_unix(sshd:session): session closed for user buildbot
EOF

cat > /var/log/syslog <<'EOF'
Mar 13 02:17:01 forge-07 CRON[1098]: (buildbot) CMD (find /var/cache/forge/buildbot -type f -mtime +7 -delete)
Mar 13 04:30:01 forge-07 CRON[1142]: (qa) CMD (find /srv/forge/reports -type f -mtime +30 -delete)
Mar 14 00:12:19 forge-07 forge-agent[1174]: build queue idle; workspace check complete
Mar 14 01:44:07 forge-07 forge-agent[1388]: release bundle checksum verified
Mar 14 02:17:01 forge-07 CRON[1582]: (buildbot) CMD (find /var/cache/forge/buildbot -type f -mtime +7 -delete)
Mar 14 03:00:00 forge-07 systemd[1]: Started Daily apt download activities.
Mar 14 04:30:01 forge-07 CRON[2011]: (qa) CMD (find /srv/forge/reports -type f -mtime +30 -delete)
EOF

touch -d '2025-03-14 03:16:00 UTC' /home/buildbot/.ssh/authorized_keys
touch -d '2025-03-13 17:42:00 UTC' /home/deploy/.ssh/authorized_keys
touch -d '2025-03-12 16:10:00 UTC' /home/buildbot/.bash_history
touch -d '2025-03-13 08:24:00 UTC' /home/deploy/.bash_history
touch -d '2025-03-13 11:03:00 UTC' /home/qa/.bash_history
touch -d '2025-02-01 12:00:00 UTC' /etc/cron.d/forge-cache /etc/cron.d/forge-reports
touch -d '2025-03-14 04:31:00 UTC' /var/log/auth.log /var/log/syslog
chmod 0644 /var/log/auth.log /var/log/syslog
