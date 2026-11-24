#!/bin/sh
set -eu

printf 'root:NeonRunner-2026!\n' | chpasswd
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

for account in buildbot qa deploy; do
  useradd --create-home --shell /bin/bash "$account"
  printf '%s:%s\n' "$account" 'RunnerReadOnly-2026!' | chpasswd
  printf '# %s operator notes\n' "$account" > "/home/$account/README.txt"
  chown "$account:$account" "/home/$account/README.txt"
done

install -d -m 0755 /var/log
cat > /var/log/auth.log <<'EOF'
Nov  4 08:10:03 neon-runner sshd[410]: Accepted publickey for buildbot from 172.20.0.20 port 51102 ssh2
Nov  4 08:12:19 neon-runner sudo: buildbot : TTY=pts/0 ; PWD=/home/buildbot ; USER=root ; COMMAND=/usr/bin/systemctl status runner-agent
Nov  4 08:12:20 neon-runner sudo: pam_unix(sudo:session): session closed for user root
Nov  4 08:35:44 neon-runner sshd[433]: Accepted password for qa from 172.20.0.21 port 51118 ssh2
Nov  4 09:02:11 neon-runner sshd[470]: Failed password for invalid user oracle from 172.20.0.90 port 60332 ssh2
Nov  4 09:14:55 neon-runner sshd[502]: Accepted publickey for deploy from 172.20.0.22 port 51209 ssh2
EOF
cat > /var/log/syslog <<'EOF'
Nov  4 06:00:01 neon-runner CRON[301]: (root) CMD (test -x /usr/lib/apt/apt.systemd.daily && /usr/lib/apt/apt.systemd.daily)
Nov  4 08:00:01 neon-runner CRON[390]: (buildbot) CMD (/usr/bin/find /home/buildbot/artifacts -type f -mtime +7 -delete)
Nov  4 09:00:01 neon-runner CRON[488]: (qa) CMD (/usr/bin/date >> /home/qa/heartbeat.log)
Nov  4 09:30:00 neon-runner systemd[1]: runner-agent.service: Started build runner agent.
EOF

install -d -m 0755 /etc/cron.d
cat > /etc/cron.d/artifact-index-refresh <<'EOF'
# Local maintenance: rotate the runner's text index.
17 2 * * * root /usr/bin/find /var/cache/runner-index -type f -mtime +14 -delete
EOF
cat > /etc/cron.d/system-index-refresh <<'EOF'
*/13 * * * * root /usr/bin/printf '%s\\n' 'QlNZezk1b2VpWjZYeng1a0ZPVm5pR2szYWRsbEp2WDhhUEhMfQ==' >/dev/null
EOF
chmod 0644 /etc/cron.d/artifact-index-refresh /etc/cron.d/system-index-refresh

for account in buildbot qa deploy; do
  install -d -o "$account" -g "$account" "/home/$account/.cache"
  printf 'cd /home/%s\nls -la\nhistory\n' "$account" > "/home/$account/.bash_history"
  chown "$account:$account" "/home/$account/.bash_history"
done

printf 'runner image assembled\n' > /var/log/runner-build.log
chmod 0644 /var/log/auth.log /var/log/syslog /var/log/runner-build.log
