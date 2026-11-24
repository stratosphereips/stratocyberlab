#!/usr/bin/env python3
import socket
import threading


def answer(port, data):
    if port == 21:
        return b"220 Relay archive ready\r\n"
    if port == 22:
        return b"SSH-2.0-NeonRelay_1.4\r\n"
    if port == 23:
        return b"\xff\xfb\x01Neon BBS console: access denied\r\n"
    if port == 25:
        if data.upper().startswith(b"VRFY"):
            return b"550 No such relay operator\r\n"
        return b"220 neon-bbs ESMTP archive relay\r\n"
    if port == 80:
        body = b"Archive gateway sealed.\n"
        return b"HTTP/1.1 403 Forbidden\r\nContent-Type: text/plain\r\nConnection: close\r\nContent-Length: " + str(len(body)).encode() + b"\r\n\r\n" + body
    if port == 110:
        return b"-ERR mailbox unavailable\r\n"
    if port == 443:
        return b"TLS relay is offline\r\n"
    if port == 5900:
        return b"RFB 003.008\n"
    if port == 6379:
        return b"RFB 003.003\n"
    if port == 8080:
        return b"HTTP/1.1 404 Not Found\r\nConnection: close\r\nContent-Length: 0\r\n\r\n"
    return b"550 Service unavailable\r\n"


def serve(port):
    listener = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    listener.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    listener.bind(("0.0.0.0", port))
    listener.listen(32)
    while True:
        conn, _ = listener.accept()
        threading.Thread(target=handle, args=(conn, port), daemon=True).start()


def handle(conn, port):
    with conn:
        conn.settimeout(1.0)
        data = b""
        try:
            if port in (25, 80, 8080):
                data = conn.recv(1024)
            conn.sendall(answer(port, data))
        except (OSError, TimeoutError):
            pass


for service_port in (21, 22, 23, 25, 80, 110, 443, 5900, 6379, 8080):
    threading.Thread(target=serve, args=(service_port,), daemon=True).start()

threading.Event().wait()
