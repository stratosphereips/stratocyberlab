from http.server import BaseHTTPRequestHandler, HTTPServer


class CabinetScreen(BaseHTTPRequestHandler):
    def do_GET(self):
        body = b"ALERT: scoreboard uplink suspended\\n"
        self.send_response(403)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        pass


HTTPServer(("0.0.0.0", 80), CabinetScreen).serve_forever()
