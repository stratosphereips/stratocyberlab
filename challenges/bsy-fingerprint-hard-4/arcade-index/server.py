import socket
import struct

HOST = "0.0.0.0"
PORT = 40443
ZONE = "arcade.local"
FLAG = "BSY{lKxOywtwJ2GlK9jm69Ivap7kdCRdi5Yr}"


def read_exact(conn, size):
    chunks = bytearray()
    while len(chunks) < size:
        part = conn.recv(size - len(chunks))
        if not part:
            return None
        chunks.extend(part)
    return bytes(chunks)


def read_name(packet, offset):
    labels = []
    while offset < len(packet):
        length = packet[offset]
        offset += 1
        if length == 0:
            break
        if length & 0xC0 or offset + length > len(packet):
            raise ValueError("compressed or malformed question")
        labels.append(packet[offset:offset + length].decode("ascii", "strict"))
        offset += length
    return ".".join(labels).lower(), offset


def wire_name(name):
    return b"".join(bytes((len(label),)) + label.encode("ascii") for label in name.split(".")) + b"\0"


def rr(record_type, data):
    return b"\xc0\x0c" + struct.pack("!HHIH", record_type, 1, 60, len(data)) + data


def response(query):
    if len(query) < 12:
        return None
    txid, flags, qdcount, _, _, _ = struct.unpack("!HHHHHH", query[:12])
    if qdcount != 1 or flags & 0x8000:
        return None
    try:
        qname, end = read_name(query, 12)
        qtype, qclass = struct.unpack("!HH", query[end:end + 4])
    except (ValueError, struct.error, UnicodeError):
        return None
    question = query[12:end + 4]
    answers = b""
    count = 0
    if qname == ZONE and qclass == 1 and qtype == 252:
        soa_data = wire_name("ns.arcade.local") + wire_name("hostmaster.arcade.local") + struct.pack("!IIIII", 2026112301, 3600, 600, 86400, 60)
        flag_bytes = FLAG.encode("ascii")
        txt_data = bytes((len(flag_bytes),)) + flag_bytes
        answers = rr(6, soa_data) + rr(16, txt_data) + rr(6, soa_data)
        count = 3
    header = struct.pack("!HHHHHH", txid, 0x8400, 1, count, 0, 0)
    return header + question + answers


def serve(conn):
    with conn:
        prefix = read_exact(conn, 2)
        if prefix is None:
            return
        length = struct.unpack("!H", prefix)[0]
        query = read_exact(conn, length)
        if query is None:
            return
        answer = response(query)
        if answer is not None:
            conn.sendall(struct.pack("!H", len(answer)) + answer)


with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server:
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((HOST, PORT))
    server.listen(32)
    while True:
        client, _ = server.accept()
        try:
            serve(client)
        except (OSError, ValueError):
            client.close()
