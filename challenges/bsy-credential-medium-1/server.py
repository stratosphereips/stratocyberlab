from base64 import b64decode
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path

USERNAME = "relay"
PASSWORD = "neon-otter-77"
FLAG = Path("/app/flag.txt").read_text().strip()


class Handler(BaseHTTPRequestHandler):
    def respond(self, status, body, content_type="text/plain; charset=utf-8", headers=None):
        data = body.encode()
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(data)))
        for key, value in (headers or {}).items():
            self.send_header(key, value)
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        if self.path == "/":
            self.respond(
                200,
                '<!doctype html><title>Ghost Relay</title>'
                '<h1>Ghost Relay</h1><p>Collective paste archive relay.</p>'
                '<ul><li><a href="/handoff.txt">Migration handoff record</a></li>'
                '<li><a href="/archive">Collective archive</a></li></ul>',
                "text/html; charset=utf-8",
            )
            return

        if self.path == "/handoff.txt":
            self.respond(
                200,
                "GHOST RELAY / handoff copy\n\n"
                "Mirror account: relay\n"
                "Passphrase: neon-otter-77\n\n"
                "Keep the archive private after login. The migration crew has gone dark.\n",
            )
            return

        if self.path == "/archive":
            supplied = self.headers.get("Authorization", "")
            valid = False
            if supplied.startswith("Basic "):
                try:
                    decoded = b64decode(supplied[6:], validate=True).decode()
                    valid = decoded == f"{USERNAME}:{PASSWORD}"
                except (ValueError, UnicodeDecodeError):
                    pass
            if not valid:
                self.respond(
                    401,
                    "ACCESS DENIED\n",
                    headers={"WWW-Authenticate": 'Basic realm="Ghost Relay Archive"'},
                )
                return
            self.respond(200, f"Archive record: {FLAG}\n")
            return

        self.respond(404, "Not found\n")

    def log_message(self, fmt, *args):
        pass


HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
