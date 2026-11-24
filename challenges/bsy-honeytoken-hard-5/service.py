#!/usr/bin/env python3
import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

FLAG = "BSY{xanwZb34QqfchgzrcJGoj7APBKmtgLWk}"
SNAPSHOT_AT = "2025-10-12T08:30:00Z"
RECORDS = [
    {"label": "relay-cache", "credential": "bg_live_7f31c9a2", "issued_at": "2025-10-13T09:02:11Z", "batch": "continuity-refresh"},
    {"label": "ops-mirror", "credential": "bg_live_d4b820e1", "issued_at": "2025-10-13T09:02:14Z", "batch": "continuity-refresh"},
    {"label": "archive-sync", "credential": "bg_live_91ac05f6", "issued_at": "2025-10-11T22:17:43Z", "batch": "legacy-operations"},
    {"label": "telemetry-pipe", "credential": "bg_live_2e6d13b8", "issued_at": "2025-10-13T09:02:18Z", "batch": "continuity-refresh"},
    {"label": "incident-mirror", "credential": "bg_live_aa08c471", "issued_at": "2025-10-13T09:02:21Z", "batch": "continuity-refresh"}
]
REAL_CREDENTIAL = "bg_live_91ac05f6"

class Handler(BaseHTTPRequestHandler):
    server_version = "BlackglassRelay/2.4"

    def send_body(self, status, body, content_type="application/json", headers=None):
        encoded = body.encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(encoded)))
        for key, value in (headers or {}).items():
            self.send_header(key, value)
        self.end_headers()
        self.wfile.write(encoded)

    def do_GET(self):
        path = urlparse(self.path)
        if path.path == "/":
            page = """<!doctype html><title>Blackglass Relay</title>
<h1>Blackglass Relay</h1><p>Credential vault interface: online.</p>
<ul><li><a href='/catalog.json'>Credential inventory</a></li>
<li><a href='/status.json'>Relay status</a></li>
<li><a href='/openapi.json'>Interface reference</a></li></ul>"""
            return self.send_body(200, page, "text/html; charset=utf-8")
        if path.path == "/catalog.json":
            return self.send_body(200, json.dumps({"exported_at": SNAPSHOT_AT, "credentials": RECORDS}))
        if path.path == "/status.json":
            return self.send_body(200, json.dumps({"relay": "degraded", "inventory_snapshot": SNAPSHOT_AT, "vault": "read-only"}))
        if path.path == "/openapi.json":
            schema = {
                "service": "Blackglass Relay Vault API",
                "version": "2.4",
                "routes": {
                    "GET /catalog.json": "Credential inventory",
                    "GET /status.json": "Relay status metadata",
                    "GET /vault/retrieve?credential=<credential>": "Retrieve the surviving vault record"
                }
            }
            return self.send_body(200, json.dumps(schema))
        if path.path == "/vault/retrieve":
            credential = parse_qs(path.query).get("credential", [""])[0]
            if credential == REAL_CREDENTIAL:
                return self.send_body(200, json.dumps({"record": "blackglass-recovery", "flag": FLAG}))
            if any(row["credential"] == credential for row in RECORDS):
                return self.send_body(403, json.dumps({"error": "credential rejected", "audit": "security event recorded"}), headers={"X-Canary-Alert": "triggered"})
            return self.send_body(401, json.dumps({"error": "unknown credential"}))
        return self.send_body(404, json.dumps({"error": "not found"}))

    def log_message(self, fmt, *args):
        pass

if __name__ == "__main__":
    ThreadingHTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
