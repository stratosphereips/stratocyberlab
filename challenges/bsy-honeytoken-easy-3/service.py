import json
import os
import socket
import subprocess
import time


def resp_command(*parts):
    packet = [f"*{len(parts)}\r\n".encode()]
    for part in parts:
        raw = str(part).encode()
        packet.extend([f"${len(raw)}\r\n".encode(), raw, b"\r\n"])
    return b"".join(packet)


def read_resp(sock):
    lead = sock.recv(1)
    if not lead:
        raise ConnectionError("Redis closed the connection")
    line = bytearray()
    while not line.endswith(b"\r\n"):
        chunk = sock.recv(1)
        if not chunk:
            raise ConnectionError("Redis closed the connection")
        line.extend(chunk)
    value = bytes(line[:-2])
    if lead == b"+":
        return value.decode(errors="replace")
    if lead == b"-":
        return {"error": value.decode(errors="replace")}
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
    raise ValueError("Unexpected Redis response")


def send(sock, *parts):
    sock.sendall(resp_command(*parts))
    return read_resp(sock)


def main():
    candidates = [
        {"username": "vaultsvc", "password": "orbitglass-71"},
        {"username": "nightshift", "password": "neon-orbit-22"},
        {"username": "relayadmin", "password": "cobalt-meteor-8"},
        {"username": "archivebot", "password": "starling-echo-44"}
    ]
    config = """bind 0.0.0.0
protected-mode no
port 6379
daemonize no
save ""
appendonly no
user default on nopass ~* +@all
user vaultsvc on >orbitglass-71 ~vault:flag +get
"""
    with open("/tmp/redis.conf", "w", encoding="utf-8") as stream:
        stream.write(config)
    server = subprocess.Popen(["redis-server", "/tmp/redis.conf"])
    try:
        for _ in range(60):
            try:
                with socket.create_connection(("127.0.0.1", 6379), timeout=1) as sock:
                    send(sock, "SET", "vault:candidates", json.dumps(candidates, separators=(",", ":")))
                    send(sock, "SET", "vault:flag", os.environ["FLAG"])
                    send(sock, "ACL", "SETUSER", "default", "reset", "on", "nopass", "~vault:candidates", "+ping", "+get", "+acl|users")
                break
            except OSError:
                time.sleep(0.25)
        else:
            raise RuntimeError("Redis did not become ready")
        raise SystemExit(server.wait())
    finally:
        if server.poll() is None:
            server.terminate()
            server.wait(timeout=5)


if __name__ == "__main__":
    main()
