#!/usr/bin/env python3
import json
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs

FLAG = "BSY{QM2v3NCuByd593MKZ1LvUT7TXQblOUVv}"

# The listed accounts look alike. Only the principal corroborated by the
# restoration record is present in the live authentication ledger.
ROSTER = [
    {"user": "orbit", "password": "violet-archive-73"},
    {"user": "echo", "password": "copper-comet-19"},
    {"user": "moth", "password": "silent-terminal-42"},
    {"user": "vector", "password": "blue-nebula-08"},
]
REAL_USER = "moth"
REAL_PASSWORD = "silent-terminal-42"

HOME = """<!doctype html>
<html><head><title>Relay-9 BBS</title></head>
<body><h1>Relay-9 Bulletin Board</h1>
<p>Night shift, the uplink is stable. The old public board is still carrying account records.</p>
<nav><a href='/board/roster'>Member roster</a> · <a href='/records/restore.log'>Restoration record</a></nav>
<p>Sysop note: preserve the archive before the next reboot.</p></body></html>"""

ROSTER_PAGE = """<!doctype html><html><head><title>Member roster</title></head><body>
<h1>Relay-9 member roster</h1><p>Imported access cards from the last board migration:</p><ul>
%s
</ul><p>Keep your console close and your modem closer.</p></body></html>""" % "\n".join(
    f"<li><code>{entry['user']}:{entry['password']}</code></li>" for entry in ROSTER
)

RESTORE_RECORD = """Relay-9 restoration transcript / archive copy
Timestamp: 1998-10-31T02:14:09Z
Source: production authentication ledger snapshot
Accepted principal: moth
Ledger state: enabled
The other migration cards were retained for decoy monitoring.
"""


class Handler(BaseHTTPRequestHandler):
    def send_text(self, status, body, content_type="text/plain; charset=utf-8"):
        encoded = body.encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(encoded)))
        self.end_headers()
        self.wfile.write(encoded)

    def do_GET(self):
        if self.path == "/":
            return self.send_text(200, HOME, "text/html; charset=utf-8")
        if self.path == "/board/roster":
            return self.send_text(200, ROSTER_PAGE, "text/html; charset=utf-8")
        if self.path == "/records/restore.log":
            return self.send_text(200, RESTORE_RECORD)
        if self.path == "/health":
            return self.send_text(200, "ok")
        return self.send_text(404, "No such board record.\n")

    def do_POST(self):
        if self.path != "/login":
            return self.send_text(404, "No such board service.\n")
        length = int(self.headers.get("Content-Length", "0"))
        fields = parse_qs(self.rfile.read(length).decode("utf-8", "replace"), keep_blank_values=True)
        username = fields.get("username", [""])[0]
        password = fields.get("password", [""])[0]
        if username == REAL_USER and password == REAL_PASSWORD:
            return self.send_text(200, json.dumps({"message": "Welcome back, sysop.", "flag": FLAG}) + "\n",
                                  "application/json; charset=utf-8")
        if any(item["user"] == username for item in ROSTER):
            self.log_message("honeytoken account used: %s", username)
            return self.send_text(403, "ACCESS DENIED: unusual account activity recorded.\n")
        return self.send_text(403, "ACCESS DENIED: authentication failed.\n")

    def log_message(self, format, *args):
        super().log_message(format, *args)


if __name__ == "__main__":
    HTTPServer(("0.0.0.0", 80), Handler).serve_forever()
