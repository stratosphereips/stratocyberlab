#!/usr/bin/env python3
"""Read-only SNMPv2c agent for a robotics actuator console."""
import socket

LISTEN = ("0.0.0.0", 161)
COMMUNITY = b"public"
SYS_DESCR = (1, 3, 6, 1, 2, 1, 1, 1, 0)
RECORD = (1, 3, 6, 1, 4, 1, 55555, 1, 0)


def tlv(tag, value):
    n = len(value)
    if n < 128:
        length = bytes([n])
    else:
        raw = n.to_bytes((n.bit_length() + 7) // 8, "big")
        length = bytes([0x80 | len(raw)]) + raw
    return bytes([tag]) + length + value


def integer(value):
    raw = value.to_bytes(max(1, (value.bit_length() + 7) // 8), "big")
    if raw[0] & 0x80:
        raw = b"\x00" + raw
    return tlv(0x02, raw)


def encode_oid(oid):
    values = [40 * oid[0] + oid[1], *oid[2:]]
    encoded = bytearray()
    for value in values:
        groups = [value & 0x7f]
        value >>= 7
        while value:
            groups.append(0x80 | (value & 0x7f))
            value >>= 7
        encoded.extend(reversed(groups))
    return tlv(0x06, bytes(encoded))


def read_tlv(data, offset=0):
    if offset + 2 > len(data):
        raise ValueError("short TLV")
    tag = data[offset]
    offset += 1
    first = data[offset]
    offset += 1
    if first & 0x80:
        count = first & 0x7f
        if count == 0 or offset + count > len(data):
            raise ValueError("invalid length")
        size = int.from_bytes(data[offset:offset + count], "big")
        offset += count
    else:
        size = first
    end = offset + size
    if end > len(data):
        raise ValueError("short value")
    start = offset - (2 if first < 0x80 else 2 + (first & 0x7f))
    return tag, data[offset:end], data[start:end], end


def fields(data):
    result = []
    offset = 0
    while offset < len(data):
        tag, value, encoded, offset = read_tlv(data, offset)
        result.append((tag, value, encoded))
    return result


def decode_oid(raw):
    values = []
    value = 0
    for byte in raw:
        value = (value << 7) | (byte & 0x7f)
        if not byte & 0x80:
            values.append(value)
            value = 0
    if not values:
        raise ValueError("empty OID")
    first = values.pop(0)
    if first < 40:
        return (0, first, *values)
    if first < 80:
        return (1, first - 40, *values)
    return (2, first - 80, *values)


def response(version, community, request_id, bindings):
    varbinds = tlv(0x30, b"".join(bindings))
    pdu = tlv(0xA2, request_id + integer(0) + integer(0) + varbinds)
    return tlv(0x30, version + community + pdu)


def process(packet):
    outer_tag, outer_value, _, _ = read_tlv(packet)
    if outer_tag != 0x30:
        return None
    outer = fields(outer_value)
    if len(outer) != 3 or outer[2][0] not in (0xA0, 0xA1):
        return None
    if outer[1][1] != COMMUNITY:
        return None
    pdu = fields(outer[2][1])
    if len(pdu) != 4:
        return None
    request_type = outer[2][0]
    values = {
        SYS_DESCR: b"Frame 68 robotics actuator console; maintenance records are indexed under the enterprise tree.",
        RECORD: open("/srv/protected-record.txt", encoding="utf-8").read().strip().encode(),
    }
    answers = []
    for binding_tag, binding_value, _ in fields(pdu[3][1]):
        if binding_tag != 0x30:
            continue
        request_parts = fields(binding_value)
        if not request_parts:
            continue
        requested_oid = decode_oid(request_parts[0][1])
        result = None
        result_oid = requested_oid
        if request_type == 0xA0:  # GetRequest
            result = values.get(requested_oid)
        elif request_type == 0xA1:  # GetNextRequest
            next_item = next(((oid, value) for oid, value in sorted(values.items()) if oid > requested_oid), None)
            if next_item:
                result_oid, result = next_item
        if result is None:
            answers.append(tlv(0x30, encode_oid(requested_oid) + tlv(0x81, b"")))
        else:
            answers.append(tlv(0x30, encode_oid(result_oid) + tlv(0x04, result)))
    if not answers:
        return None
    return response(outer[0][2], outer[1][2], pdu[0][2], answers)


def main():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(LISTEN)
    while True:
        packet, peer = sock.recvfrom(65535)
        try:
            reply = process(packet)
            if reply:
                sock.sendto(reply, peer)
        except (IndexError, ValueError, OSError):
            continue


if __name__ == "__main__":
    main()
