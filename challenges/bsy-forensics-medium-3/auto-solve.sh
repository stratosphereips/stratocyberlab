#!/usr/bin/env bash
set -euo pipefail
HOST=172.20.0.141
LOGIN=analyst
PASSWORD='MoonDust-74'
CHALLENGE_ID=scl-challenge-frame-80b93d
ENCODED=$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$LOGIN@$HOST" "grep -F 'incident-' /home/analyst/.ssh/authorized_keys | cut -d ' ' -f3 | cut -d '-' -f2-")
FLAG=$(printf '%s' "$ENCODED" | base64 -d)
python3 -c 'import json,sys; print(json.dumps({"challenge_id":sys.argv[1],"task_id":"task1","flag":sys.argv[2]}), end="")' "$CHALLENGE_ID" "$FLAG" | curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary @-
