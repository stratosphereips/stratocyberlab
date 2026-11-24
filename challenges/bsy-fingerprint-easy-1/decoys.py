import socketserver
import threading


class BannerHandler(socketserver.BaseRequestHandler):
    def handle(self):
        self.request.settimeout(2)
        try:
            self.request.sendall(b"SSH-2.0-OpenSSH_9.2p1 Mainframe Gateway\r\n")
            self.request.recv(512)
            self.request.sendall(b"Access denied: operator authorization required.\r\n")
        except (OSError, TimeoutError):
            pass


class Server(socketserver.ThreadingTCPServer):
    allow_reuse_address = True
    daemon_threads = True


for port in (22, 2322):
    server = Server(("0.0.0.0", port), BannerHandler)
    threading.Thread(target=server.serve_forever, daemon=True).start()

threading.Event().wait()
