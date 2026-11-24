import socketserver
import threading

FLAG = "BSY{xIJlVM0vr4pJFDJlfww9BWsVnTRVR5WO}"


class NNTPHandler(socketserver.StreamRequestHandler):
    def handle(self):
        self.wfile.write(b"200 Ares telemetry relay ready\r\n")
        while True:
            raw = self.rfile.readline(4096)
            if not raw:
                return
            parts = raw.decode("ascii", "replace").strip().split()
            if not parts:
                continue
            command = parts[0].upper()
            args = parts[1:]

            if command == "CAPABILITIES":
                self.multiline(b"101 Capability list follows", [b"VERSION 2", b"READER", b"LIST ACTIVE", b"POST"])
            elif command == "LIST":
                self.multiline(b"215 list follows", [b"mars.telemetry 1 1 y"])
            elif command == "GROUP":
                if args and args[0].lower() == "mars.telemetry":
                    self.wfile.write(b"211 1 1 1 mars.telemetry\r\n")
                else:
                    self.wfile.write(b"411 no such group\r\n")
            elif command in ("ARTICLE", "BODY", "HEAD"):
                if not args or args[0] not in ("1", "<rover-1@ares.relay>"):
                    self.wfile.write(b"430 no such article\r\n")
                    continue
                if command == "ARTICLE":
                    self.wfile.write(b"220 1 <rover-1@ares.relay> article follows\r\n")
                    lines = [b"From: telemetry@ares.local", b"Newsgroups: mars.telemetry", b"Subject: Final rover burst", b"", FLAG.encode("ascii")]
                    self.write_lines(lines)
                elif command == "HEAD":
                    self.wfile.write(b"221 1 <rover-1@ares.relay> headers follow\r\n")
                    self.write_lines([b"From: telemetry@ares.local", b"Newsgroups: mars.telemetry", b"Subject: Final rover burst", b""])
                else:
                    self.wfile.write(b"222 1 <rover-1@ares.relay> body follows\r\n")
                    self.write_lines([FLAG.encode("ascii")])
            elif command == "QUIT":
                self.wfile.write(b"205 closing connection\r\n")
                return
            else:
                self.wfile.write(b"500 command not recognized\r\n")

    def write_lines(self, lines):
        for line in lines:
            if line.startswith(b"."):
                line = b"." + line
            self.wfile.write(line + b"\r\n")
        self.wfile.write(b".\r\n")

    def multiline(self, status, lines):
        self.wfile.write(status + b"\r\n")
        self.write_lines(lines)


class SSHDecoy(socketserver.StreamRequestHandler):
    def handle(self):
        self.wfile.write(b"SSH-2.0-OpenSSH_9.6p1 Ubuntu-4ubuntu0.3\r\n")


class HTTPDecoy(socketserver.StreamRequestHandler):
    def handle(self):
        self.request.recv(2048)
        body = b"Access denied: relay maintenance channel\n"
        self.wfile.write(b"HTTP/1.1 403 Forbidden\r\nContent-Type: text/plain\r\nConnection: close\r\nContent-Length: " + str(len(body)).encode() + b"\r\n\r\n" + body)


class ThreadedServer(socketserver.ThreadingTCPServer):
    allow_reuse_address = True
    daemon_threads = True


def serve(port, handler):
    server = ThreadedServer(("0.0.0.0", port), handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    return server


if __name__ == "__main__":
    servers = [serve(8022, NNTPHandler), serve(2222, SSHDecoy), serve(8080, HTTPDecoy)]
    threading.Event().wait()
