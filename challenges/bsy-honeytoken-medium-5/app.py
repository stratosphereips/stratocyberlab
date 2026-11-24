#!/usr/bin/env python3
"""A small HTTP file share seeded with honeytoken credentials."""
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse
import json

CANDIDATES = [
    {"label": "sync-node-a", "credential": "choir_sync_7f1a"},
    {"label": "sync-node-b", "credential": "choir_sync_92bd"},
    {"label": "mirror-agent", "credential": "choir_mirror_44ce"},
    {"label": "archive-reader", "credential": "choir_archive_d301"},
]
ACTIVE_CREDENTIAL = "choir_archive_d301"

class Handler(BaseHTTPRequestHandler):
    server_version = "ChoirShare/1.4"

    def send_body(self, status, body, content_type="text/html; charset=utf-8"):
        data = body.encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path == "/":
            self.send_body(200, """<!doctype html><title>Null Choir Share</title>
<h1>Null Choir file share</h1>
<p>Relay status: degraded. Cached artifacts remain available.</p>
<ul><li><a href='/share/index.json'>Shared access inventory</a></li>
<li><a href='/backup/rotation.ini'>Operations rotation copy</a></li>
<li><a href='/archive'>Collective archive</a></li></ul>""")
        elif parsed.path == "/share/index.json":
            body = {"share": "choir-cache", "credentials": CANDIDATES}
            self.send_body(200, json.dumps(body), "application/json; charset=utf-8")
        elif parsed.path == "/backup/rotation.ini":
            self.send_body(200, """; Null Choir mirror rotation snapshot
[mirror]
status=online
active_credential=choir_archive_d301
last_verified=2026-10-18T03:14:00Z
""", "text/plain; charset=utf-8")
        elif parsed.path == "/archive":
            params = parse_qs(parsed.query)
            credential = params.get("credential", [""])[0]
            known = {item["credential"] for item in CANDIDATES}
            if credential == ACTIVE_CREDENTIAL:
                self.send_body(200, json.dumps({"archive": "null-choir/blackbox", "status": "opened", "flag": "BSY{ujhl7XHnQ0DKJr0F05Q3ItsbDCBL97fN}"}), "application/json; charset=utf-8")
            elif credential in known:
                self.send_body(403, json.dumps({"status": "access denied", "notice": "Honeytoken event recorded for collective review."}), "application/json; charset=utf-8")
            else:
                self.send_body(401, json.dumps({"status": "credential required"}), "application/json; charset=utf-8")
        else:
            self.send_body(404, "<h1>Not found</h1>")

    def log_message(self, fmt, *args):
        # Keep access logging visible as a normal service signal.
        super().log_message(fmt, *args)

if __name__ == "__main__":
    ThreadingHTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
