#!/bin/sh
set -eu

for account in buildbot release metrics; do
    useradd --create-home --shell /bin/bash "$account"
    passwd --lock "$account" >/dev/null
    install -m 0600 -o "$account" -g "$account" /dev/null "/home/$account/.bash_history"
done

cat > /home/buildbot/.bash_history <<'EOF'
cd /srv/runner
ls -la
./run-build.sh
EOF
cat > /home/release/.bash_history <<'EOF'
git status --short
sudo -l
systemctl status runner-agent
EOF
cat > /home/metrics/.bash_history <<'EOF'
df -h
uptime
journalctl -n 5
EOF
chown buildbot:buildbot /home/buildbot/.bash_history
chown release:release /home/release/.bash_history
chown metrics:metrics /home/metrics/.bash_history

cat > /root/.bash_history <<'EOF'
who
last -n 3
systemctl status ssh
EOF
chmod 0600 /root/.bash_history

cat > /var/log/auth.log <<'EOF'
Nov 20 09:10:14 neon-runner sshd[410]: Server listening on 0.0.0.0 port 22.
Nov 20 09:12:02 neon-runner sshd[426]: Accepted publickey for buildbot from 172.20.0.20 port 51224 ssh2
Nov 20 09:15:41 neon-runner sudo: release : TTY=pts/0 ; PWD=/srv/runner ; USER=root ; COMMAND=/usr/bin/systemctl status runner-agent
Nov 20 09:16:03 neon-runner sudo: release : TTY=pts/0 ; PWD=/srv/runner ; USER=root ; COMMAND=/usr/bin/journalctl -n 5
Nov 20 09:18:27 neon-runner sshd[451]: Accepted publickey for metrics from 172.20.0.21 port 51310 ssh2
EOF
chmod 0644 /var/log/auth.log

cat > /var/log/syslog <<'EOF'
Nov 20 09:00:00 neon-runner systemd[1]: Started Daily apt download activities.
Nov 20 09:11:00 neon-runner CRON[418]: (root) CMD (/usr/local/sbin/runner-healthcheck)
Nov 20 09:22:00 neon-runner runner-agent[504]: Build queue idle.
EOF
chmod 0644 /var/log/syslog

cat > /etc/sudoers.d/release-ops <<'EOF'
release ALL=(root) /usr/bin/systemctl status runner-agent, /usr/bin/journalctl -n 5
EOF
chmod 0440 /etc/sudoers.d/release-ops

mkdir -p /srv/runner
printf '%s\n' 'runner workspace' > /srv/runner/README.txt
chown -R buildbot:buildbot /srv/runner

touch -d '2026-11-18 10:00:00 UTC' /home/buildbot/.bash_history /home/release/.bash_history /home/metrics/.bash_history /root/.bash_history /var/log/auth.log /var/log/syslog /etc/cron.d/runner-health /etc/sudoers.d/release-ops
