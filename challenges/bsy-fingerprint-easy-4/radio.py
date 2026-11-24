import socketserver
import threading

FLAG = "BSY{isvFHwZVxRuZCjc30XG5PYPHB4ICJhMN}"


class SMTPHandler(socketserver.StreamRequestHandler):
    def handle(self):
        self.wfile.write(b"220 dead-air-rig ESMTP ready\r\n")
        while True:
            raw = self.rfile.readline(2048)
            if not raw:
                return
            line = raw.decode("ascii", "replace").strip()
            if not line:
                continue
            command, _, argument = line.partition(" ")
            command = command.upper()
            argument = argument.strip()
            if command in ("EHLO", "HELO"):
                self.wfile.write(b"250-dead-air-rig\r\n250-SIZE 2048\r\n250 HELP\r\n")
            elif command == "VRFY":
                if argument.lower() == "radio":
                    reply = f'250 2.1.5 "{FLAG}" <radio@dead-air.invalid>\r\n'
                    self.wfile.write(reply.encode("ascii"))
                else:
                    self.wfile.write(b"550 5.1.1 No such user\r\n")
            elif command == "HELP":
                self.wfile.write(b"214 ESMTP service ready\r\n")
            elif command == "QUIT":
                self.wfile.write(b"221 dead-air-rig closing connection\r\n")
                return
            else:
                self.wfile.write(b"502 5.5.1 Command not implemented\r\n")


class VNCDecoyHandler(socketserver.StreamRequestHandler):
    def handle(self):
        self.wfile.write(b"RFB 003.008\n")
        self.wfile.flush()
        self.rfile.readline(64)
        reason = b"Maintenance only"
        self.wfile.write(b"\x00\x00\x00" + len(reason).to_bytes(4, "big") + reason)


class ThreadedTCPServer(socketserver.ThreadingTCPServer):
    allow_reuse_address = True
    daemon_threads = True


def serve(port, handler):
    server = ThreadedTCPServer(("0.0.0.0", port), handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    return server


if __name__ == "__main__":
    servers = [
        serve(25252, SMTPHandler),
        serve(5900, VNCDecoyHandler),
        serve(5901, VNCDecoyHandler),
    ]
    threading.Event().wait()
