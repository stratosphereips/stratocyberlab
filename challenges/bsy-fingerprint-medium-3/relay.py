import socket
import threading

FLAG = "BSY{hzYPSyX5TJ27pa7UusbJaj0dlec07m6q}"
MQTT_PORT = 80
DECOY_PORT = 1883
TOPIC = "mars/rover/blackbox/recovery"


def mqtt_string(value):
    data = value.encode()
    return len(data).to_bytes(2, "big") + data


def mqtt_packet(header, body):
    remaining = len(body)
    encoded = bytearray()
    while True:
        digit = remaining % 128
        remaining //= 128
        if remaining:
            digit |= 0x80
        encoded.append(digit)
        if not remaining:
            break
    return bytes([header]) + bytes(encoded) + body


def read_packet(conn):
    first = conn.recv(1)
    if not first:
        return None
    length = 0
    multiplier = 1
    for _ in range(4):
        raw = conn.recv(1)
        if not raw:
            return None
        digit = raw[0]
        length += (digit & 127) * multiplier
        if not digit & 128:
            break
        multiplier *= 128
    else:
        return None
    body = bytearray()
    while len(body) < length:
        chunk = conn.recv(length - len(body))
        if not chunk:
            return None
        body.extend(chunk)
    return first[0], bytes(body)


def matches(topic_filter, topic):
    filters = topic_filter.split("/")
    levels = topic.split("/")
    for index, part in enumerate(filters):
        if part == "#":
            return index == len(filters) - 1
        if index >= len(levels):
            return False
        if part != "+" and part != levels[index]:
            return False
    return len(filters) == len(levels)


def handle_mqtt(conn):
    try:
        conn.settimeout(8)
        packet = read_packet(conn)
        if not packet or packet[0] >> 4 != 1:
            return
        body = packet[1]
        if len(body) < 7 or body[2:6] != b"MQTT" or body[6] != 4:
            conn.sendall(b"\x20\x02\x00\x01")
            return
        conn.sendall(b"\x20\x02\x00\x00")
        while True:
            packet = read_packet(conn)
            if not packet:
                return
            header, body = packet
            if header >> 4 != 8 or len(body) < 5:
                continue
            packet_id = body[:2]
            topic_len = int.from_bytes(body[2:4], "big")
            if len(body) < 4 + topic_len + 1:
                continue
            topic_filter = body[4:4 + topic_len].decode("utf-8", "replace")
            conn.sendall(mqtt_packet(0x90, packet_id + b"\x00"))
            if matches(topic_filter, TOPIC):
                conn.sendall(mqtt_packet(0x30, mqtt_string(TOPIC) + FLAG.encode()))
    except (OSError, ValueError):
        pass
    finally:
        conn.close()


def handle_decoy(conn):
    try:
        conn.settimeout(2)
        conn.recv(2048)
        conn.sendall(
            b"HTTP/1.1 403 Forbidden\r\n"
            b"Content-Type: text/plain\r\n"
            b"Connection: close\r\n\r\n"
            b"RELAY ACCESS DENIED: operator authorization required.\n"
        )
    except OSError:
        pass
    finally:
        conn.close()


def serve(port, handler):
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(("0.0.0.0", port))
    server.listen(64)
    while True:
        conn, _ = server.accept()
        threading.Thread(target=handler, args=(conn,), daemon=True).start()


threading.Thread(target=serve, args=(DECOY_PORT, handle_decoy), daemon=True).start()
serve(MQTT_PORT, handle_mqtt)
