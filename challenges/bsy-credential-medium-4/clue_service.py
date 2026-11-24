from http.server import BaseHTTPRequestHandler, HTTPServer

NOTE = b"AIRLOCK MAINTENANCE\nOperator account: panel_ops / orbit-73\n"


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.send_header("Content-Length", str(len(NOTE)))
        self.end_headers()
        self.wfile.write(NOTE)

    def log_message(self, format, *args):
        pass


HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
