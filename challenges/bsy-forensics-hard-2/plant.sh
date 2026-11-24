#!/bin/sh
set -eu

useradd -m -s /bin/bash analyst
printf '%s\n' 'analyst:Orbit-Deck-47' | chpasswd
usermod -aG sudo analyst
printf '%s\n' 'analyst ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/analyst
chmod 0440 /etc/sudoers.d/analyst

for spec in 'mira:ops' 'kellan:engineering' 'rhea:science'; do
  name=${spec%%:*}
  group=${spec#*:}
  useradd -m -s /bin/bash "$name"
  mkdir -p "/home/$name/.cache"
  printf '# routine %s maintenance\nls -la ~\n' "$group" > "/home/$name/.bash_history"
  chown -R "$name:$name" "/home/$name"
done

mkdir -p /var/tmp/.cache
printf '%s\n' 'QlNZe1hDd2hLMzJnNXFpMWY2SDdGTk1KaGc0STc0bEQxTThHfQ==' > /var/tmp/.cache/.telemetry
chmod 0600 /var/tmp/.cache/.telemetry
chown root:root /var/tmp/.cache/.telemetry
touch -d '2021-06-12 04:15:00 UTC' /var/tmp/.cache/.telemetry

mkdir -p /etc/cron.d
cat > /etc/cron.d/station-maintenance <<'EOF'
# Apparent station intrusion lead. This host's cron daemon is not started.
*/5 * * * * root curl -fsS http://198.51.100.77/keepalive >/dev/null 2>&1
EOF
chmod 0644 /etc/cron.d/station-maintenance

mkdir -p /var/log
cat > /var/log/auth.log <<'EOF'
Nov 18 08:12:03 abandoned-jump sshd[410]: Accepted password for mira from 172.20.0.31 port 51220 ssh2
Nov 18 08:17:44 abandoned-jump sudo: mira : TTY=pts/0 ; PWD=/home/mira ; USER=root ; COMMAND=/usr/bin/systemctl status cron
Nov 18 09:02:10 abandoned-jump sshd[522]: Accepted publickey for kellan from 172.20.0.32 port 51271 ssh2
Nov 18 09:14:39 abandoned-jump sudo: kellan : TTY=pts/1 ; PWD=/home/kellan ; USER=root ; COMMAND=/usr/bin/apt list --upgradable
Nov 18 10:21:06 abandoned-jump sshd[811]: Accepted password for rhea from 172.20.0.33 port 51308 ssh2
Nov 18 10:26:55 abandoned-jump sudo: rhea : TTY=pts/2 ; PWD=/home/rhea ; USER=root ; COMMAND=/usr/bin/journalctl -n 20
Nov 18 11:03:17 abandoned-jump sudo: mira : TTY=pts/0 ; PWD=/home/mira ; USER=root ; COMMAND=/usr/bin/install -m 0644 station-maintenance /etc/cron.d/station-maintenance
EOF
cat > /var/log/syslog <<'EOF'
Nov 18 08:00:01 abandoned-jump CRON[201]: (root) CMD (run-parts --report /etc/cron.hourly)
Nov 18 09:00:01 abandoned-jump CRON[306]: (root) CMD (run-parts --report /etc/cron.hourly)
Nov 18 10:00:01 abandoned-jump CRON[405]: (root) CMD (run-parts --report /etc/cron.hourly)
Nov 18 11:00:01 abandoned-jump CRON[509]: (root) CMD (run-parts --report /etc/cron.hourly)
EOF

printf '# prior interactive commands unavailable\n' > /home/analyst/.bash_history
chown analyst:analyst /home/analyst/.bash_history
chmod 0600 /home/analyst/.bash_history
