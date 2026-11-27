from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import socket
import threading

USERNAME = "actuator-op"
PASSWORD = "orbit7"


class WebHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/":
            body = (
                "<html><title>Actuator Lab Handoff</title>"
                "<h1>Actuator Lab Handoff</h1>"
                "<p>Maintenance shift notes are staged for the incoming crew.</p>"
                "<a href='/handoff.txt'>Shift handoff note</a></html>"
            ).encode()
            content_type = "text/html; charset=utf-8"
            status = 200
        elif self.path == "/handoff.txt":
            body = (
                "ROBOTICS LAB / NIGHT SHIFT\n"
                "Console operator account: " + USERNAME + "\n"
                "Temporary access phrase: " + PASSWORD + "\n"
                "Keep these details inside the lab.\n"
            ).encode()
            content_type = "text/plain; charset=utf-8"
            status = 200
        else:
            body = b"Not found\n"
            content_type = "text/plain; charset=utf-8"
            status = 404
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        pass


def telnet_client(conn):
    conn.settimeout(30)
    file = conn.makefile("rwb", buffering=0)

    def say(text):
        file.write(text.encode())

    try:
        say("Strato Robotics Actuator Console / Telnet\r\nOperator login required.\r\n")
        say("login: ")
        username = file.readline(256).decode(errors="ignore").strip()
        say("password: ")
        password = file.readline(256).decode(errors="ignore").strip()
        if username != USERNAME or password != PASSWORD:
            say("Access denied. Security event logged.\r\n")
            return
        say("Welcome, operator. Commands: help, status, logout\r\n> ")
        while True:
            line = file.readline(512)
            if not line:
                break
            command = line.decode(errors="ignore").strip().lower()
            if command == "help":
                say("Available commands: help, status, logout\r\n")
            elif command == "status":
                say("Protected actuator record: BSY{41whmdnBsZMOrjd2B6HluFf4CzL2DYcB}\r\n")
            elif command == "logout":
                say("Session closed.\r\n")
                break
            else:
                say("Unknown command.\r\n")
            say("> ")
    except (OSError, UnicodeError):
        pass
    finally:
        try:
            file.close()
        except OSError:
            pass
        conn.close()


def telnet_server():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(("0.0.0.0", 23))
    server.listen(32)
    while True:
        conn, _ = server.accept()
        threading.Thread(target=telnet_client, args=(conn,), daemon=True).start()


threading.Thread(target=telnet_server, daemon=True).start()
ThreadingHTTPServer(("0.0.0.0", 8080), WebHandler).serve_forever()
