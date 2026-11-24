#!/usr/bin/env python3
import socket


def tlv(tag, value):
    n = len(value)
    if n < 128:
        length = bytes([n])
    else:
        raw = n.to_bytes((n.bit_length() + 7) // 8, "big")
        length = bytes([0x80 | len(raw)]) + raw
    return bytes([tag]) + length + value


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


binding = tlv(0x30, oid((1, 3, 6, 1, 2, 1, 1, 1, 0)) + tlv(0x05, b""))
pdu = tlv(0xA0, tlv(0x02, b"\x07") + tlv(0x02, b"\x00") + tlv(0x02, b"\x00") + tlv(0x30, binding))
request = tlv(0x30, tlv(0x02, b"\x01") + tlv(0x04, b"public") + pdu)
with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as client:
    client.settimeout(2)
    client.sendto(request, ("127.0.0.1", 161))
    reply, _ = client.recvfrom(4096)
    if not reply:
        raise SystemExit(1)
