#!/bin/sh
set -eu
HOST='172.20.0.141'
USER='root'
PASS='NeonRunner-2026!'

line=$(sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR "$USER@$HOST" 'cat /etc/cron.d/system-index-refresh')
encoded=$(printf '%s\n' "$line" | python3 -c 'import re,sys; s=sys.stdin.read(); m=re.search(r"\x27([A-Za-z0-9+/]+={0,2})\x27", s); sys.exit("encoded value not found") if not m else print(m.group(1))')
flag=$(python3 -c 'import base64,sys; print(base64.b64decode(sys.argv[1], validate=True).decode())' "$encoded")
payload=$(python3 -c 'import json,sys; print(json.dumps({"challenge_id":"scl-challenge-frame-8c0f4d","task_id":"task1","flag":sys.argv[1]}))' "$flag")
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "$payload"
