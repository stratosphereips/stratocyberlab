#!/usr/bin/env python3
from base64 import b64decode
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from io import BytesIO
from zipfile import ZIP_DEFLATED, ZipFile

FLAG = "BSY{AW8uBKUXelKsKp8nXdwIevFFSNuyynAF}"
USERNAME = "operator"
PASSWORD = "orbit"


def make_backup():
    data = BytesIO()
    with ZipFile(data, "w", ZIP_DEFLATED) as archive:
        archive.writestr(
            "relay.ini",
            "[control]\nusername = operator\npassword = orbit\n",
        )
    return data.getvalue()


BACKUP = make_backup()


class RelayHandler(BaseHTTPRequestHandler):
    server_version = "PasteRelay/1.4"

    def send_body(self, status, body, content_type="text/html; charset=utf-8", headers=()):
        encoded = body if isinstance(body, bytes) else body.encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(encoded)))
        for key, value in headers:
            self.send_header(key, value)
        self.end_headers()
        self.wfile.write(encoded)

    def authorized(self):
        header = self.headers.get("Authorization", "")
        if not header.startswith("Basic "):
            return False
        try:
            supplied = b64decode(header[6:]).decode("utf-8")
        except Exception:
            return False
        return supplied == f"{USERNAME}:{PASSWORD}"

    def require_auth(self):
        if self.authorized():
            return True
        self.send_body(
            401,
            "Authentication required\n",
            "text/plain; charset=utf-8",
            (("WWW-Authenticate", 'Basic realm="Ghost Paste Control"'),),
        )
        return False

    def do_GET(self):
        if self.path == "/health":
            self.send_body(200, "ok\n", "text/plain; charset=utf-8")
        elif self.path == "/":
            self.send_body(
                200,
                """<!doctype html><title>Ghost Paste Relay</title>
<h1>Ghost Paste Relay</h1>
<p>Collective paste relay // uplink stable</p>
<ul><li><a href="/public/ops-backup.zip">Public operations archive</a></li>
<li><a href="/control/">Control room</a></li></ul>
""",
            )
        elif self.path == "/public/ops-backup.zip":
            self.send_body(
                200,
                BACKUP,
                "application/zip",
                (("Content-Disposition", 'attachment; filename="ops-backup.zip"'),),
            )
        elif self.path == "/control/":
            if self.require_auth():
                self.send_body(
                    200,
                    """<!doctype html><title>Control room</title>
<h1>Control room</h1><p>Relay access granted.</p>
<a href="/control/record.txt">Read the protected relay record</a>
""",
                )
        elif self.path == "/control/record.txt":
            if self.require_auth():
                self.send_body(200, FLAG + "\n", "text/plain; charset=utf-8")
        else:
            self.send_body(404, "Not found\n", "text/plain; charset=utf-8")

    def log_message(self, fmt, *args):
        pass


ThreadingHTTPServer(("0.0.0.0", 80), RelayHandler).serve_forever()
