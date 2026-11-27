import os
import socket
import threading

HOST = "0.0.0.0"
POP3_PORT = 21110
SSH_DECOY_PORT = 2222
HTTP_DECOY_PORT = 8080
FLAG = os.environ["FLAG"]


def read_line(conn):
    data = bytearray()
    while not data.endswith(b"\n"):
        chunk = conn.recv(1)
        if not chunk:
            return None
        data.extend(chunk)
        if len(data) > 4096:
            return None
    return data.decode("ascii", "replace").strip()


def pop3_session(conn):
    logged_in = False
    user_seen = False
    try:
        conn.sendall(b"+OK MIDNIGHT MAINFRAME mailbox ready\r\n")
        while True:
            line = read_line(conn)
            if line is None:
                break
            parts = line.split()
            if not parts:
                conn.sendall(b"-ERR empty command\r\n")
                continue
            command = parts[0].upper()
            args = parts[1:]

            if command == "USER" and len(args) == 1:
                user_seen = args[0] == "archive"
                conn.sendall(b"+OK mailbox user accepted\r\n" if user_seen else b"-ERR unknown mailbox\r\n")
            elif command == "PASS" and len(args) == 1:
                logged_in = user_seen and args[0] == "terminal"
                conn.sendall(b"+OK mailbox locked and loaded\r\n" if logged_in else b"-ERR authentication failed\r\n")
            elif command == "QUIT":
                conn.sendall(b"+OK closing connection\r\n")
                break
            elif command == "NOOP":
                conn.sendall(b"+OK\r\n")
            elif command in ("STAT", "LIST", "RETR") and not logged_in:
                conn.sendall(b"-ERR authenticate first\r\n")
            elif command == "STAT":
                conn.sendall(b"+OK 1 96\r\n")
            elif command == "LIST":
                conn.sendall(b"+OK 1 message (96 octets)\r\n1 96\r\n.\r\n")
            elif command == "RETR" and args == ["1"]:
                message = (
                    "From: archive@midnight.local\r\n"
                    "Subject: recovered terminal record\r\n"
                    "\r\n"
                    f"{FLAG}\r\n"
                )
                conn.sendall(b"+OK 96 octets\r\n")
                for item in message.splitlines():
                    if item.startswith("."):
                        item = "." + item
                    conn.sendall(item.encode("ascii") + b"\r\n")
                conn.sendall(b".\r\n")
            elif command == "RETR":
                conn.sendall(b"-ERR no such message\r\n")
            else:
                conn.sendall(b"-ERR unsupported command\r\n")
    except (ConnectionError, OSError):
        pass
    finally:
        try:
            conn.close()
        except OSError:
            pass


def ssh_decoy(conn):
    try:
        conn.sendall(b"SSH-2.0-OpenSSH_9.6p1 Debian-1\r\n")
        conn.settimeout(2)
        conn.recv(256)
    except (ConnectionError, OSError):
        pass
    finally:
        conn.close()


def http_decoy(conn):
    try:
        conn.settimeout(2)
        conn.recv(2048)
        body = b"MAINFRAME CONSOLE SEALED\n"
        response = (
            b"HTTP/1.1 403 Forbidden\r\n"
            b"Content-Type: text/plain\r\n"
            + f"Content-Length: {len(body)}\r\n".encode("ascii")
            + b"Connection: close\r\n\r\n"
            + body
        )
        conn.sendall(response)
    except (ConnectionError, OSError):
        pass
    finally:
        conn.close()


def serve(port, handler):
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind((HOST, port))
    server.listen(32)
    while True:
        conn, _ = server.accept()
        threading.Thread(target=handler, args=(conn,), daemon=True).start()


for port, handler in (
    (POP3_PORT, pop3_session),
    (SSH_DECOY_PORT, ssh_decoy),
    (HTTP_DECOY_PORT, http_decoy),
):
    threading.Thread(target=serve, args=(port, handler), daemon=True).start()

threading.Event().wait()
