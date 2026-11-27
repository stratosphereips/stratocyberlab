#!/bin/sh
set -eu

HOST=172.20.0.141
USER=root
PASSWORD='NeonRunner!47'
CHALLENGE_ID=scl-challenge-frame-885f11

# The cron artifact is part of the host's static forensic tableau; cron is not started.
artifact=$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$USER@$HOST" 'cat /etc/cron.d/telemetry')
encoded=$(printf '%s\n' "$artifact" | sed -n 's/.*ticket=\([A-Za-z0-9+/=]*\).*/\1/p')
flag=$(printf '%s' "$encoded" | python3 -c 'import base64,sys; print(base64.b64decode(sys.stdin.read()).decode())')

payload=$(python3 -c 'import json,sys; print(json.dumps({"challenge_id":sys.argv[1],"task_id":"task1","flag":sys.argv[2]}))' "$CHALLENGE_ID" "$flag")
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "$payload"
