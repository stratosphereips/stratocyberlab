#!/bin/sh
set -eu

FLAG="$(python3 - <<'PY'
import re
import socket

host = "172.20.0.149"
port = 8022
with socket.create_connection((host, port), timeout=5) as sock:
    sock.settimeout(5)
    stream = sock.makefile("rwb", buffering=0)
    greeting = stream.readline()
    if not greeting.startswith(b"200 "):
        raise SystemExit("Unexpected service greeting")

    stream.write(b"CAPABILITIES\r\n")
    status = stream.readline()
    if not status.startswith(b"101 "):
        raise SystemExit("Unexpected capabilities response")
    while stream.readline().rstrip(b"\r\n") != b".":
        pass

    stream.write(b"LIST ACTIVE\r\n")
    status = stream.readline()
    if not status.startswith(b"215 "):
        raise SystemExit("Unexpected group-list response")
    groups = []
    while True:
        line = stream.readline().rstrip(b"\r\n")
        if line == b".":
            break
        groups.append(line)
    if not any(line.split() and line.split()[0] == b"mars.telemetry" for line in groups):
        raise SystemExit("Telemetry group not found")

    stream.write(b"GROUP mars.telemetry\r\n")
    if not stream.readline().startswith(b"211 "):
        raise SystemExit("Could not select telemetry group")
    stream.write(b"ARTICLE 1\r\n")
    if not stream.readline().startswith(b"220 "):
        raise SystemExit("Could not retrieve the article")

    body = []
    while True:
        line = stream.readline().rstrip(b"\r\n")
        if line == b".":
            break
        body.append(line)

    match = next((re.fullmatch(rb"BSY\{[^}]+\}", line) for line in body if re.fullmatch(rb"BSY\{[^}]+\}", line)), None)
    if match is None:
        raise SystemExit("Proof token not found in article")
    print(match.group().decode("ascii"))
PY
)"
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' \
  --data-binary "{\"challenge_id\":\"scl-challenge-frame-49c00c\",\"task_id\":\"task1\",\"flag\":\"$FLAG\"}"
