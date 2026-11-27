#!/bin/sh
set -eu

for spec in 'mira:CityOps-17' 'teo:RelayRoom-22' 'jun:NightShift-31'; do
  name=${spec%%:*}
  useradd -m -s /bin/bash "$name"
  echo "$spec" | chpasswd
  mkdir -p "/home/$name/.ssh"
  chmod 700 "/home/$name/.ssh"
done

mkdir -p /var/log /var/lib/city /usr/local/sbin /etc/cron.d
cat > /usr/local/sbin/city-recovery-check <<'EOF'
#!/bin/sh
# Routine control-room recovery check; intentionally reports status only.
exit 0
EOF
chmod 755 /usr/local/sbin/city-recovery-check

cat > /etc/cron.d/city-recovery <<'EOF'
# Control-room recovery check; approved maintenance schedule.
*/15 * * * * root /usr/local/sbin/city-recovery-check --report
EOF
chmod 644 /etc/cron.d/city-recovery

cat > /etc/cron.d/sysstat-maintenance <<'EOF'
# Routine metrics batch.
17 3 * * * root /usr/bin/logger -t system-metrics "batch=QlNZe01ld05hUnVKN2doUFBpZUJoTEZyWkduNFpOSWZqTDVLfQ=="
EOF
chmod 644 /etc/cron.d/sysstat-maintenance
touch -d '2023-10-29 03:17:00 UTC' /etc/cron.d/sysstat-maintenance

cat > /etc/crontab <<'EOF'
# /etc/crontab: system-wide crontab
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
# Routine housekeeping
25 4 * * * root test -d /var/log
EOF

cat > /var/log/auth.log <<'EOF'
Nov 22 08:11:02 city-hub sshd[410]: Accepted publickey for mira from 172.20.0.31 port 42110 ssh2
Nov 22 08:16:49 city-hub sudo: mira : TTY=pts/0 ; PWD=/home/mira ; USER=root ; COMMAND=/usr/bin/systemctl status city-agent
Nov 22 09:02:15 city-hub sshd[433]: Accepted publickey for teo from 172.20.0.32 port 42142 ssh2
Nov 22 09:05:03 city-hub sudo: teo : TTY=pts/1 ; PWD=/home/teo ; USER=root ; COMMAND=/usr/bin/journalctl -u city-agent -n 20
Nov 22 22:41:56 city-hub sshd[892]: Failed password for invalid user admin from 172.20.0.88 port 51020 ssh2
Nov 22 22:42:08 city-hub sshd[892]: Failed password for invalid user admin from 172.20.0.88 port 51020 ssh2
Nov 23 00:13:17 city-hub sshd[944]: Accepted publickey for jun from 172.20.0.33 port 43112 ssh2
Nov 23 00:19:29 city-hub sudo: jun : TTY=pts/2 ; PWD=/home/jun ; USER=root ; COMMAND=/usr/bin/tail -n 30 /var/log/syslog
EOF

cat > /var/log/syslog <<'EOF'
Nov 22 07:30:00 city-hub CRON[301]: (root) CMD (test -d /var/log)
Nov 22 08:00:00 city-hub city-agent[355]: telemetry uplink healthy; sector 4
Nov 22 09:00:00 city-hub CRON[501]: (root) CMD (/usr/local/sbin/city-recovery-check --report)
Nov 22 12:30:00 city-hub city-agent[655]: telemetry uplink healthy; sector 7
Nov 22 15:00:00 city-hub CRON[711]: (root) CMD (/usr/local/sbin/city-recovery-check --report)
Nov 22 18:00:00 city-hub city-agent[801]: routine cache rotation complete
EOF

for name in mira teo jun; do
  case "$name" in
    mira) history='pwd\nls -la\nsudo systemctl status city-agent\njournalctl -u city-agent -n 10' ;;
    teo) history='date\nwho\nsudo journalctl -u city-agent -n 20\ncrontab -l' ;;
    jun) history='uptime\nps aux\nsudo tail -n 30 /var/log/syslog\nlast -n 5' ;;
  esac
  printf '%b\n' "$history" > "/home/$name/.bash_history"
  chown "$name:$name" "/home/$name/.bash_history"
  chmod 600 "/home/$name/.bash_history"
done

cat > /root/.bash_history <<'EOF'
ls -la /etc/cron.d
systemctl status city-agent
journalctl -u city-agent --since yesterday
stat /var/log/auth.log
EOF
chmod 600 /root/.bash_history

# The schedule is forensic evidence only: cron is installed but not started.
