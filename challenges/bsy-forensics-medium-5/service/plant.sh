#!/bin/bash
set -euo pipefail

# Routine board operations accounts.
useradd -m -s /bin/bash moderator
useradd -m -s /bin/bash archivist
useradd -m -s /bin/bash feedbot
useradd -m -s /bin/bash syncboard

cat > /var/log/auth.log <<'LOG'
Nov  5 08:14:22 board-archive sshd[810]: Accepted password for moderator from 172.20.0.22 port 51102 ssh2
Nov  5 08:16:01 board-archive sudo: moderator : TTY=pts/0 ; PWD=/home/moderator ; USER=root ; COMMAND=/usr/bin/systemctl status nginx
Nov  5 12:02:45 board-archive sshd[1140]: Failed password for root from 198.51.100.66 port 40881 ssh2
Nov  5 12:02:49 board-archive sshd[1140]: Failed password for root from 198.51.100.66 port 40881 ssh2
Nov  5 12:03:11 board-archive sshd[1140]: Connection closed by authenticating user root 198.51.100.66 port 40881 [preauth]
Nov  5 18:37:04 board-archive sshd[2031]: Accepted password for archivist from 172.20.0.24 port 51490 ssh2
Nov  5 18:41:17 board-archive sudo: archivist : TTY=pts/1 ; PWD=/home/archivist ; USER=root ; COMMAND=/usr/bin/journalctl --since today
Nov  5 23:47:36 board-archive sshd[3928]: Accepted publickey for syncboard from 203.0.113.77 port 60142 ssh2: ED25519 SHA256:PLACEHOLDER_FINGERPRINT
LOG

cat > /var/log/syslog <<'LOG'
Nov  5 06:00:01 board-archive CRON[701]: (root) CMD (test -x /usr/sbin/anacron || true)
Nov  5 06:15:01 board-archive CRON[744]: (feedbot) CMD (/usr/local/bin/board-feed-check --quiet)
Nov  5 12:00:01 board-archive CRON[1330]: (archivist) CMD (/usr/local/bin/archive-index --daily)
Nov  5 18:00:01 board-archive CRON[2050]: (root) CMD (run-parts --report /etc/cron.hourly)
Nov  5 23:47:36 board-archive sshd[3928]: Accepted publickey for syncboard from 203.0.113.77 port 60142 ssh2
LOG

# Ordinary, inert maintenance schedules.
cat > /etc/cron.d/board-maintenance <<'CRON'
15 2 * * * archivist /usr/local/bin/archive-index --daily
*/20 * * * * feedbot /usr/local/bin/board-feed-check --quiet
CRON
chmod 644 /etc/cron.d/board-maintenance

# Familiar shell activity for the regular operators.
cat > /home/moderator/.bash_history <<'HIST'
cd /srv/bulletin
ls -la
sudo systemctl status nginx
less /var/log/nginx/access.log
HIST
cat > /home/archivist/.bash_history <<'HIST'
cd /srv/archive
find . -type f -mtime -7
/usr/local/bin/archive-index --daily
journalctl --since today
HIST
cat > /home/feedbot/.bash_history <<'HIST'
/usr/local/bin/board-feed-check --quiet
ls -lh /var/cache/board
HIST
chown moderator:moderator /home/moderator/.bash_history
chown archivist:archivist /home/archivist/.bash_history
chown feedbot:feedbot /home/feedbot/.bash_history
chmod 600 /home/moderator/.bash_history /home/archivist/.bash_history /home/feedbot/.bash_history

# One inert persistence artifact: a public key with an encoded note.
install -d -m 0700 -o syncboard -g syncboard /home/syncboard/.ssh
ssh-keygen -q -t ed25519 -N '' -C 'board-sync@board-archive' -f /tmp/board-sync-key
printf '%s flag-b64=QlNZe3BvY2xVNUlWaEd3REtBRGcyQmhrWVVjbEZqWEt0NGo1fQ==\n' "$(cat /tmp/board-sync-key.pub)" > /home/syncboard/.ssh/authorized_keys
chown syncboard:syncboard /home/syncboard/.ssh/authorized_keys
chmod 600 /home/syncboard/.ssh/authorized_keys
fingerprint="$(ssh-keygen -lf /tmp/board-sync-key.pub | awk '{print $2}')"
sed -i "s/PLACEHOLDER_FINGERPRINT/${fingerprint}/g" /var/log/auth.log
rm -f /tmp/board-sync-key /tmp/board-sync-key.pub

# Plausible timestamps for the seeded tableau.
touch -t 202611050805 /home/moderator/.bash_history
touch -t 202611051831 /home/archivist/.bash_history
touch -t 202611050612 /home/feedbot/.bash_history
touch -t 202611052347 /home/syncboard/.ssh/authorized_keys
