import socket
import threading

HOST = "0.0.0.0"
POP3_PORT = 21110
MESSAGE = b"From: arcade-archive\r\nSubject: Final score record\r\n\r\nCabinet record recovered. Championship token: BSY{RpQnwzRuOMBonlC8rqlbu2aSYEDL0D6p}\r\n"


def send_line(conn, value):
    conn.sendall(value.encode("ascii") + b"\r\n")


def pop3_client(conn):
    authenticated = False
    username_ok = False
    try:
        conn.settimeout(30)
        send_line(conn, "+OK Pixel Palace archive ready. Operator login: guest / quarter")
        reader = conn.makefile("rb")
        while True:
            raw = reader.readline(4096)
            if not raw:
                break
            parts = raw.decode("ascii", "ignore").strip().split()
            if not parts:
                send_line(conn, "-ERR empty command")
                continue
            command = parts[0].upper()
            args = parts[1:]
            if command == "QUIT":
                send_line(conn, "+OK cabinet signing off")
                break
            if command == "USER" and len(args) == 1:
                username_ok = args[0] == "guest"
                send_line(conn, "+OK mailbox selected" if username_ok else "-ERR unknown mailbox")
            elif command == "PASS" and len(args) == 1:
                authenticated = username_ok and args[0] == "quarter"
                send_line(conn, "+OK mailbox unlocked" if authenticated else "-ERR access denied")
            elif command in ("STAT", "LIST", "RETR") and not authenticated:
                send_line(conn, "-ERR authenticate first")
            elif command == "STAT":
                send_line(conn, f"+OK 1 {len(MESSAGE)}")
            elif command == "LIST":
                send_line(conn, "+OK 1 message")
                send_line(conn, f"1 {len(MESSAGE)}")
                send_line(conn, ".")
            elif command == "RETR" and args == ["1"]:
                send_line(conn, f"+OK {len(MESSAGE)} octets")
                conn.sendall(MESSAGE.replace(b"\n", b"\r\n").replace(b"\r\r\n", b"\r\n") + b".\r\n")
            elif command == "RETR":
                send_line(conn, "-ERR no such message")
            else:
                send_line(conn, "-ERR unsupported command")
    except (OSError, TimeoutError):
        pass
    finally:
        try:
            conn.close()
        except OSError:
            pass


def serve_pop3():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.bind((HOST, POP3_PORT))
    sock.listen(32)
    while True:
        conn, _ = sock.accept()
        threading.Thread(target=pop3_client, args=(conn,), daemon=True).start()


def decoy_client(conn, port):
    try:
        conn.settimeout(2)
        if port == 22:
            conn.sendall(b"SSH-2.0-OpenSSH_9.2p1 Ubuntu-2\r\n")
        else:
            conn.sendall(b"HTTP/1.1 403 Forbidden\r\nConnection: close\r\nContent-Length: 22\r\n\r\nCabinet access denied.\n")
    except OSError:
        pass
    finally:
        conn.close()


def serve_decoy(port):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.bind((HOST, port))
    sock.listen(16)
    while True:
        conn, _ = sock.accept()
        threading.Thread(target=decoy_client, args=(conn, port), daemon=True).start()


for port in (22, 80):
    threading.Thread(target=serve_decoy, args=(port,), daemon=True).start()
serve_pop3()
