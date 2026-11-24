import socket
import threading

FINGER_PORT = 25252
HTTP_PORT = 8080
VNC_PORT = 5900


def finger_client(conn):
    try:
        conn.settimeout(3)
        request = conn.recv(1024).decode("utf-8", "replace").splitlines()
        query = request[0].strip().split("@", 1)[0].strip().lower() if request else ""
        if not query:
            response = (
                "Login       Name                 Tty  Idle  Login Time  Office\r\n"
                "archive     Relay archive desk   *          02:14  Orbital Hub\r\n"
            )
        elif query == "archive":
            response = (
                "Login: archive\r\n"
                "Name: Relay archive desk\r\n"
                "Directory: /srv/relay/archive\r\n"
                "Shell: /usr/sbin/nologin\r\n"
                "On since: last signal before blackout\r\n"
                "Plan:\r\n"
                "Black-box recovery record: BSY{5Xgw6105aMvCuHGCgrRfP9C5a02pVW6n}\r\n"
            )
        else:
            response = f"{query}: no such user on the relay.\r\n"
        conn.sendall(response.encode())
    except (OSError, TimeoutError):
        pass
    finally:
        conn.close()


def http_client(conn):
    try:
        conn.settimeout(2)
        conn.recv(1024)
        body = b"Gateway sealed. Crew credentials required.\n"
        reply = (
            b"HTTP/1.1 403 Forbidden\r\nContent-Type: text/plain\r\n"
            + f"Content-Length: {len(body)}\r\nConnection: close\r\n\r\n".encode()
            + body
        )
        conn.sendall(reply)
    except OSError:
        pass
    finally:
        conn.close()


def vnc_client(conn):
    try:
        conn.settimeout(2)
        conn.sendall(b"RFB 003.008\n")
        conn.recv(64)
        conn.sendall(b"Security required; relay console locked.\n")
    except OSError:
        pass
    finally:
        conn.close()


def serve(port, handler):
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(("0.0.0.0", port))
    server.listen(32)
    while True:
        conn, _ = server.accept()
        threading.Thread(target=handler, args=(conn,), daemon=True).start()


for port, handler in (
    (FINGER_PORT, finger_client),
    (HTTP_PORT, http_client),
    (VNC_PORT, vnc_client),
):
    threading.Thread(target=serve, args=(port, handler), daemon=True).start()

threading.Event().wait()
