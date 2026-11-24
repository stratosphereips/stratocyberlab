#!/usr/bin/env python3
"""Quiet MQTT 3.1.1 door controller with harmless HTTP decoys."""
import socket
import struct
import sys
import threading

MQTT_PORT = 1887
RETAINED = {"hackspace/door/controller/recovery": "BSY{tGHpvAne1KBfA5PPAxhzYL2bQ8oSTEJ3}"}


def read_exact(conn, count):
    data = bytearray()
    while len(data) < count:
        part = conn.recv(count - len(data))
        if not part:
            return None
        data.extend(part)
    return bytes(data)


def read_packet(conn):
    first = read_exact(conn, 1)
    if first is None:
        return None
    multiplier = 1
    remaining = 0
    for _ in range(4):
        data = read_exact(conn, 1)
        if data is None:
            return None
        digit = data[0]
        remaining += (digit & 127) * multiplier
        if digit < 128:
            break
        multiplier *= 128
    else:
        return None
    body = read_exact(conn, remaining)
    if body is None:
        return None
    return first[0], body


def encode_length(length):
    encoded = bytearray()
    while True:
        digit = length % 128
        length //= 128
        if length:
            digit |= 128
        encoded.append(digit)
        if not length:
            return bytes(encoded)


def packet(header, body):
    return bytes((header,)) + encode_length(len(body)) + body


def topic_matches(topic_filter, topic):
    filters = topic_filter.split("/")
    parts = topic.split("/")
    for index, part in enumerate(filters):
        if part == "#":
            return index == len(filters) - 1
        if index >= len(parts):
            return False
        if part != "+" and part != parts[index]:
            return False
    return len(filters) == len(parts)


def mqtt_client(conn):
    with conn:
        conn.settimeout(12)
        connected = False
        while True:
            try:
                item = read_packet(conn)
            except (OSError, TimeoutError):
                return
            if item is None:
                return
            kind, body = item
            packet_type = kind >> 4
            if packet_type == 1:
                # MQTT 3.1.1 CONNECT: length-prefixed protocol name, level, flags, keepalive.
                if len(body) < 10 or body[:2] != b"\x00\x04" or body[2:7] != b"MQTT\x04":
                    conn.sendall(packet(0x20, b"\x00\x01"))
                    return
                conn.sendall(packet(0x20, b"\x00\x00"))
                connected = True
            elif packet_type == 8 and connected:
                if len(body) < 5:
                    return
                packet_id = body[:2]
                position = 2
                filters = []
                granted = []
                while position + 2 <= len(body):
                    size = struct.unpack("!H", body[position:position + 2])[0]
                    position += 2
                    if position + size + 1 > len(body):
                        return
                    filters.append(body[position:position + size].decode("utf-8", "replace"))
                    position += size
                    qos = body[position]
                    position += 1
                    granted.append(min(qos, 1))
                if not filters:
                    return
                conn.sendall(packet(0x90, packet_id + bytes(granted)))
                for topic, value in RETAINED.items():
                    if any(topic_matches(topic_filter, topic) for topic_filter in filters):
                        name = topic.encode("utf-8")
                        payload = value.encode("utf-8")
                        conn.sendall(packet(0x31, struct.pack("!H", len(name)) + name + payload))
            elif packet_type == 12 and connected:
                conn.sendall(packet(0xD0, b""))
            elif packet_type == 14:
                return


def mqtt_server():
    server = socket.socket()
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(("0.0.0.0", MQTT_PORT))
    server.listen(40)
    while True:
        conn, _ = server.accept()
        threading.Thread(target=mqtt_client, args=(conn,), daemon=True).start()


def http_decoy(conn):
    with conn:
        try:
            conn.settimeout(2)
            conn.recv(4096)
            body = b"Door controller status: access denied.\n"
            response = (b"HTTP/1.1 403 Forbidden\r\nContent-Type: text/plain\r\n"
                        b"Connection: close\r\nContent-Length: " + str(len(body)).encode()
                        + b"\r\n\r\n" + body)
            conn.sendall(response)
        except OSError:
            pass


def decoy_server(port):
    server = socket.socket()
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(("0.0.0.0", port))
    server.listen(30)
    while True:
        conn, _ = server.accept()
        threading.Thread(target=http_decoy, args=(conn,), daemon=True).start()


def healthcheck():
    with socket.create_connection(("127.0.0.1", MQTT_PORT), timeout=2) as conn:
        client_id = b"healthcheck"
        body = b"\x00\x04MQTT\x04\x02\x00\x3c" + struct.pack("!H", len(client_id)) + client_id
        conn.sendall(packet(0x10, body))
        if read_packet(conn) != (0x20, b"\x00\x00"):
            raise SystemExit(1)


if __name__ == "__main__":
    if "--healthcheck" in sys.argv:
        healthcheck()
    else:
        for port in (8000, 8080, 8888):
            threading.Thread(target=decoy_server, args=(port,), daemon=True).start()
        mqtt_server()
