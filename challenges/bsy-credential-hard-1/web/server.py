import base64
import hmac
import os
from http.server import BaseHTTPRequestHandler, HTTPServer

USER = os.environ["ACCESS_USER"]
PASSWORD = os.environ["ACCESS_PASSWORD"]

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        supplied = self.headers.get("Authorization", "")
        expected = "Basic " + base64.b64encode(f"{USER}:{PASSWORD}".encode()).decode()
        if not hmac.compare_digest(supplied, expected):
            self.send_response(401)
            self.send_header("WWW-Authenticate", 'Basic realm="Nova Archive"')
            self.end_headers()
            self.wfile.write(b"Archive access denied. Credentials required.\n")
            return
        with open("/app/flag.txt", "rb") as record:
            body = record.read()
        self.send_response(200)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        pass

HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
