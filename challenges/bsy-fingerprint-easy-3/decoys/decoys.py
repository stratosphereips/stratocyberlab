from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from threading import Thread


class GroundStationStub(BaseHTTPRequestHandler):
    def do_GET(self):
        body = b"403 - Ground station access denied. This endpoint is not accepting telemetry.\n"
        self.send_response(403)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        pass


def serve(port):
    ThreadingHTTPServer(("0.0.0.0", port), GroundStationStub).serve_forever()


for port in (80, 8080):
    Thread(target=serve, args=(port,), daemon=True).start()

ThreadingHTTPServer(("0.0.0.0", 8090), GroundStationStub).serve_forever()
