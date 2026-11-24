#!/bin/sh
set -eu
HOST=172.20.0.141
LOGIN_USER=root
PASSWORD=neonforge-44
CHALLENGE_ID=scl-challenge-frame-d1b4b8

nmap -n -p 22 --open "$HOST" >/dev/null
encoded=$(SSHPASS="$PASSWORD" sshpass -e ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$LOGIN_USER@$HOST" "grep -a -o 'SCL_NOTE_B64=[A-Za-z0-9+/=]*' /usr/bin/yes | head -n 1 | cut -d= -f2-")
test -n "$encoded"
flag=$(printf '%s' "$encoded" | python3 -c 'import base64,sys; print(base64.b64decode(sys.stdin.buffer.read(), validate=True).decode())')
printf 'Recovered flag: %s\n' "$flag"
printf '{"challenge_id":"%s","task_id":"task1","flag":"%s"}' "$CHALLENGE_ID" "$flag" | curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary @-
