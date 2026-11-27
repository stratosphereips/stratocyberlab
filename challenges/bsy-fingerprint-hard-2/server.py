import socket
import socketserver
import threading
import time

FLAG = "BSY{QcpZYCPRfO1UrcSeCDvV9xCeNoMq8wVP}"


class ThreadedTCPServer(socketserver.ThreadingTCPServer):
    allow_reuse_address = True
    daemon_threads = True


class SMTPHandler(socketserver.StreamRequestHandler):
    def handle(self):
        time.sleep(0.8)
        self.wfile.write(b"220 dead-letter ESMTP ready\r\n")
        self.wfile.flush()
        while True:
            raw = self.rfile.readline(1024)
            if not raw:
                return
            line = raw.decode("ascii", "replace").strip()
            parts = line.split(None, 1)
            command = parts[0].upper() if parts else ""
            argument = parts[1].strip() if len(parts) > 1 else ""
            if command in ("EHLO", "HELO"):
                self.wfile.write(b"250-dead-letter\r\n250-HELP\r\n250 VRFY\r\n")
            elif command == "HELP":
                self.wfile.write(b"214 Commands: EHLO HELO HELP NOOP VRFY RSET QUIT\r\n")
            elif command == "VRFY":
                if argument.lower() == "archivist":
                    self.wfile.write(f'250 2.1.5 "{FLAG}"@ledger.invalid\r\n'.encode())
                else:
                    self.wfile.write(b"550 5.1.1 User unknown\r\n")
            elif command in ("NOOP", "RSET"):
                self.wfile.write(b"250 2.0.0 OK\r\n")
            elif command == "QUIT":
                self.wfile.write(b"221 2.0.0 Closing connection\r\n")
                self.wfile.flush()
                return
            else:
                self.wfile.write(b"500 5.5.2 Command unrecognized\r\n")
            self.wfile.flush()


class BannerHandler(socketserver.BaseRequestHandler):
    def handle(self):
        port = self.server.server_address[1]
        try:
            if port == 5900:
                self.request.sendall(b"RFB 003.008\n")
                self.request.settimeout(1.5)
                self.request.recv(32)
                self.request.sendall(b"\x00\x00\x00\x00")
            elif port == 22:
                self.request.sendall(b"SSH-2.0-OpenSSH_8.9p1 Ubuntu-3\r\n")
            elif port == 2121:
                self.request.sendall(b"220 archive-ftp ready\r\n")
                self.request.settimeout(1.5)
                self.request.recv(128)
                self.request.sendall(b"530 Alarm: access denied\r\n")
            elif port == 8080:
                self.request.settimeout(1.5)
                self.request.recv(1024)
                self.request.sendall(
                    b"HTTP/1.1 403 Forbidden\r\nContent-Length: 22\r\nConnection: close\r\n\r\nALARM: console sealed\n"
                )
            elif port == 2323:
                self.request.sendall(b"\xff\xfb\x01\xff\xfb\x03Dead-letter console locked\r\n")
            else:
                self.request.sendall(b"Service unavailable\r\n")
        except (OSError, TimeoutError):
            pass


def serve(port, handler):
    server = ThreadedTCPServer(("0.0.0.0", port), handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()


serve(25252, SMTPHandler)
for decoy_port in (22, 5900, 2121, 2323, 8080):
    serve(decoy_port, BannerHandler)

threading.Event().wait()
