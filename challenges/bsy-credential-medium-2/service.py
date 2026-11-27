from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import socketserver
import threading

CREW_RECORD = Path("/srv/crew-record.txt")
USERNAME = "relay"
PASSWORD = "orbit-1977"


class PasteHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory="/srv/public", **kwargs)


class TelnetHandler(socketserver.StreamRequestHandler):
    def read_line(self):
        data = bytearray()
        while True:
            byte = self.rfile.read(1)
            if not byte:
                return None
            if byte == b"\xff":  # Refuse optional Telnet features; plain line mode is enough.
                command = self.rfile.read(1)
                if command in (b"\xfb", b"\xfc", b"\xfd", b"\xfe"):
                    option = self.rfile.read(1)
                    if command == b"\xfb":
                        self.wfile.write(b"\xff\xfe" + option)
                        self.wfile.flush()
                    elif command == b"\xfd":
                        self.wfile.write(b"\xff\xfc" + option)
                        self.wfile.flush()
                continue
            if byte == b"\n":
                return data.rstrip(b"\r").decode("utf-8", "replace")
            data.extend(byte)

    def handle(self):
        self.wfile.write(b"Ghostline relay terminal\r\nlogin: ")
        self.wfile.flush()
        username = self.read_line()
        if username is None:
            return
        self.wfile.write(b"Password: ")
        self.wfile.flush()
        password = self.read_line()
        if username != USERNAME or password != PASSWORD:
            self.wfile.write(b"Login incorrect\r\n")
            self.wfile.flush()
            return

        self.wfile.write(b"Welcome, relay. Type help for available commands.\r\n$ ")
        self.wfile.flush()
        while True:
            line = self.read_line()
            if line is None:
                return
            command = line.strip()
            if command in ("exit", "logout", "quit"):
                self.wfile.write(b"Connection closed.\r\n")
                self.wfile.flush()
                return
            if command == "help":
                response = b"Commands: help, pwd, ls, cat <file>, exit\r\n"
            elif command == "pwd":
                response = b"/home/relay\r\n"
            elif command == "ls":
                response = b"crew-record.txt\r\n"
            elif command in (
                "cat crew-record.txt",
                "cat /home/relay/crew-record.txt",
                "cat ~/crew-record.txt",
            ):
                response = CREW_RECORD.read_bytes()
                if not response.endswith(b"\n"):
                    response += b"\r\n"
            else:
                response = b"Permission denied or unknown command.\r\n"
            self.wfile.write(response + b"$ ")
            self.wfile.flush()


class TelnetServer(socketserver.ThreadingTCPServer):
    allow_reuse_address = True
    daemon_threads = True


http = ThreadingHTTPServer(("0.0.0.0", 80), PasteHandler)
threading.Thread(target=http.serve_forever, daemon=True).start()
with TelnetServer(("0.0.0.0", 23), TelnetHandler) as telnet:
    telnet.serve_forever()
