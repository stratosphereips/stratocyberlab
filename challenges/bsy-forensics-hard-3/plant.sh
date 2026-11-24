#!/bin/bash
set -euo pipefail

# Routine host activity for the forensic tableau.
mkdir -p /home/analyst/.local/share /home/archivist/.cache /home/buildbot/work
chown -R analyst:analyst /home/analyst
chown -R archivist:archivist /home/archivist
chown -R buildbot:buildbot /home/buildbot
printf 'nightly index refresh\n' > /home/archivist/.cache/index-note
printf 'build queue drained\n' > /home/buildbot/work/last-run.txt
printf 'export PATH="$HOME/bin:$PATH"\n' > /home/analyst/.bashrc.local
printf '15 2 * * * archivist test -d /home/archivist/.cache && find /home/archivist/.cache -type f -mtime +30 -delete\n' > /etc/cron.d/archive-sweep
chmod 0644 /etc/cron.d/archive-sweep

# A conspicuous, inert lead: the referenced utility is absent and cron is not started.
printf '*/17 * * * * root /usr/local/sbin/relay-audit --rotate\n' > /etc/cron.d/relay-audit
chmod 0644 /etc/cron.d/relay-audit

# Seed ordinary audit noise without recording the planted access material.
cat > /var/log/auth.log <<'EOF'
Nov 18 08:14:02 cracked-mainframe sshd[811]: Accepted password for analyst from 172.20.0.3 port 42110 ssh2
Nov 18 08:14:06 cracked-mainframe sudo: analyst : TTY=pts/0 ; PWD=/home/analyst ; USER=root ; COMMAND=/usr/bin/systemctl status ssh
Nov 18 08:14:07 cracked-mainframe sudo: pam_unix(sudo:session): session opened for user root(uid=0) by analyst(uid=1000)
Nov 18 08:14:11 cracked-mainframe sudo: pam_unix(sudo:session): session closed for user root
Nov 19 02:15:01 cracked-mainframe CRON[992]: (archivist) CMD (test -d /home/archivist/.cache && find /home/archivist/.cache -type f -mtime +30 -delete)
Nov 20 17:42:33 cracked-mainframe sshd[1431]: Failed password for invalid user guest from 172.20.0.3 port 43209 ssh2
Nov 20 17:42:40 cracked-mainframe sshd[1431]: Connection closed by invalid user guest 172.20.0.3 port 43209 [preauth]
Nov 21 09:05:18 cracked-mainframe sshd[1882]: Accepted password for analyst from 172.20.0.3 port 43981 ssh2
Nov 21 09:05:21 cracked-mainframe sudo: analyst : TTY=pts/1 ; PWD=/home/analyst ; USER=root ; COMMAND=/usr/bin/last
Nov 21 09:05:24 cracked-mainframe sudo: pam_unix(sudo:session): session opened for user root(uid=0) by analyst(uid=1000)
Nov 21 09:05:29 cracked-mainframe sudo: pam_unix(sudo:session): session closed for user root
EOF
chmod 0640 /var/log/auth.log

cat > /var/log/syslog <<'EOF'
Nov 18 02:15:01 cracked-mainframe CRON[712]: (archivist) CMD (test -d /home/archivist/.cache && find /home/archivist/.cache -type f -mtime +30 -delete)
Nov 19 02:15:01 cracked-mainframe CRON[992]: (archivist) CMD (test -d /home/archivist/.cache && find /home/archivist/.cache -type f -mtime +30 -delete)
Nov 20 02:15:01 cracked-mainframe CRON[1213]: (archivist) CMD (test -d /home/archivist/.cache && find /home/archivist/.cache -type f -mtime +30 -delete)
Nov 21 02:15:01 cracked-mainframe CRON[1610]: (archivist) CMD (test -d /home/archivist/.cache && find /home/archivist/.cache -type f -mtime +30 -delete)
EOF
chmod 0640 /var/log/syslog

cat > /home/analyst/.bash_history <<'EOF'
whoami
last -n 5
sudo systemctl status ssh
sudo lastlog
EOF
cat > /home/retro/.bash_history <<'EOF'
cd /srv/legacy
ls -la
sudo journalctl -n 20
exit
EOF
cat > /home/archivist/.bash_history <<'EOF'
find ~/.cache -type f -mtime +30 -delete
crontab -l
exit
EOF
cat > /home/buildbot/.bash_history <<'EOF'
cd ~/work
make clean all
exit
EOF
chown analyst:analyst /home/analyst/.bash_history
chown retro:retro /home/retro/.bash_history
chown archivist:archivist /home/archivist/.bash_history
chown buildbot:buildbot /home/buildbot/.bash_history
chmod 0600 /home/analyst/.bash_history /home/retro/.bash_history /home/archivist/.bash_history /home/buildbot/.bash_history

# A valid, unauthorized public key was planted in a normal account's SSH trust file.
# Its file timestamp was backdated; ctime remains tied to the recent image build.
ssh-keygen -q -t ed25519 -N '' -C 'field-maintenance' -f /tmp/field-key
read -r key_type key_blob _ < /tmp/field-key.pub
printf '%s %s QlNZe1NWMW0yWTh4MlFFZFNNbUNWdTNIVUY3bFlnb3N2bWxYfQ==\n' "$key_type" "$key_blob" > /home/retro/.ssh/authorized_keys
chown retro:retro /home/retro/.ssh/authorized_keys
chmod 0600 /home/retro/.ssh/authorized_keys
touch -d '2021-04-09 03:12:00 UTC' /home/retro/.ssh/authorized_keys
rm -f /tmp/field-key /tmp/field-key.pub

# Plausible historic timestamps for routine files.
touch -d '2024-08-12 10:30:00 UTC' /home/archivist/.cache/index-note /home/buildbot/work/last-run.txt
