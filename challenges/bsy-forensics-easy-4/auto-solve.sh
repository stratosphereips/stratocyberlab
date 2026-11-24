#!/bin/sh
set -eu

HOST=172.20.0.159
USER=root
PASSWORD='stargate-operator-7'
CHALLENGE_ID=scl-challenge-frame-59e8ae

ENCODED=$(sshpass -p "$PASSWORD" ssh \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  "$USER@$HOST" "getent passwd svc-frame-rebuild | cut -d: -f5")
FLAG=$(printf '%s' "$ENCODED" | base64 -d)

python3 -c 'import json,sys; print(json.dumps({"challenge_id":sys.argv[1],"task_id":"task1","flag":sys.argv[2]}),end="")' "$CHALLENGE_ID" "$FLAG" |
  curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary @-
