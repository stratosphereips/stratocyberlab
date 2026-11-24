#!/usr/bin/env python3
import socket
import threading
import time

FLAG = "BSY{zvJLVmioqJNVU8nr6mFE0LzCcplYI7Wa}"
HOST = "0.0.0.0"
POP3_PORT = 46110


def send_line(conn, value):
    conn.sendall(value.encode("ascii") + b"\r\n")


def read_line(conn):
    data = bytearray()
    while len(data) < 2048:
        byte = conn.recv(1)
        if not byte or byte == b"\n":
            break
        if byte != b"\r":
            data.extend(byte)
    return data.decode("ascii", errors="replace").strip()


def handle_pop3(conn):
    conn.settimeout(8)
    try:
        time.sleep(0.8)
        send_line(conn, "+OK Ghostline archive node ready")
        user_ok = False
        authenticated = False
        while True:
            line = read_line(conn)
            if not line:
                return
            parts = line.split(None, 1)
            command = parts[0].upper()
            arg = parts[1] if len(parts) > 1 else ""
            if command == "CAPA":
                send_line(conn, "+OK capability list follows")
                send_line(conn, "USER")
                send_line(conn, "UIDL")
                send_line(conn, ".")
            elif command == "USER":
                user_ok = arg.lower() == "archive"
                send_line(conn, "+OK mailbox selected" if user_ok else "-ERR mailbox unavailable")
            elif command == "PASS":
                authenticated = user_ok and arg == "guest"
                send_line(conn, "+OK mailbox locked and loaded" if authenticated else "-ERR authentication failed")
            elif command == "STAT":
                send_line(conn, "+OK 1 96" if authenticated else "-ERR authentication required")
            elif command == "LIST":
                if not authenticated:
                    send_line(conn, "-ERR authentication required")
                elif arg == "1":
                    send_line(conn, "+OK 1 96")
                else:
                    send_line(conn, "+OK scan listing follows")
                    send_line(conn, "1 96")
                    send_line(conn, ".")
            elif command == "UIDL":
                if authenticated:
                    send_line(conn, "+OK unique-id listing follows")
                    send_line(conn, "1 ghostline-archive-01")
                    send_line(conn, ".")
                else:
                    send_line(conn, "-ERR authentication required")
            elif command == "RETR":
                if not authenticated:
                    send_line(conn, "-ERR authentication required")
                elif arg != "1":
                    send_line(conn, "-ERR no such message")
                else:
                    send_line(conn, "+OK 96 octets")
                    send_line(conn, "From: night-operator@ghostline")
                    send_line(conn, "Subject: recovered archive key")
                    send_line(conn, "")
                    send_line(conn, FLAG)
                    send_line(conn, ".")
            elif command == "QUIT":
                send_line(conn, "+OK ghostline signing off")
                return
            else:
                send_line(conn, "-ERR command not recognized")
    except (OSError, TimeoutError):
        return
    finally:
        conn.close()


def handle_decoy(conn):
    conn.settimeout(2)
    port = conn.getsockname()[1]
    try:
        if port in (22, 2222):
            conn.sendall(b"SSH-2.0-OpenSSH_8.4p1 Debian-5\r\n")
        elif port in (80, 8080):
            body = b"Ghostline relay: access denied. Incident logged.\n"
            conn.sendall(
                b"HTTP/1.1 403 Forbidden\r\nContent-Type: text/plain\r\n"
                + f"Content-Length: {len(body)}\r\nConnection: close\r\n\r\n".encode()
                + body
            )
        elif port == 23:
            conn.sendall(b"Ghostline console sealed. Alarm logged.\r\n")
        else:
            conn.sendall(b"421 Relay closed by archive security.\r\n")
    except OSError:
        pass
    finally:
        conn.close()


def serve(port, handler):
    listener = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    listener.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    listener.bind((HOST, port))
    listener.listen(64)
    while True:
        conn, _ = listener.accept()
        threading.Thread(target=handler, args=(conn,), daemon=True).start()


if __name__ == "__main__":
    for decoy_port in (22, 23, 80, 8080, 2222):
        threading.Thread(target=serve, args=(decoy_port, handle_decoy), daemon=True).start()
    serve(POP3_PORT, handle_pop3)
