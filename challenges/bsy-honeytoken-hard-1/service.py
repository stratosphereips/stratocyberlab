#!/usr/bin/env python3
import base64
import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

IDENTITY_GENERATION = "g-7c91d2"
ROSTER = [
    {"callsign": "ION-7", "username": "mira.chen", "password": "Vanta!Relay_31", "generation": "g-7c91d2"},
    {"callsign": "KITE-2", "username": "orion.vale", "password": "Nebula-Archive-44", "generation": "g-7c91c8"},
    {"callsign": "LUMA-9", "username": "sable.ross", "password": "CrewChange#2081", "generation": "g-7c91d2a"},
    {"callsign": "MOTH-4", "username": "jax.ren", "password": "Starlight!Override", "generation": "g-7c91aa"},
    {"callsign": "NOVA-1", "username": "tess.iyer", "password": "OrionDeck_090", "generation": "g-7c91d20"}
]

class Handler(BaseHTTPRequestHandler):
    server_version = "RosterTerminal/2.4"

    def send_json(self, status, value, headers=None):
        body = json.dumps(value, separators=(",", ":")).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        for key, val in (headers or {}).items():
            self.send_header(key, val)
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/healthz":
            self.send_json(200, {"status": "ok"})
            return
        if self.path == "/":
            body = ("<!doctype html><html><head><title>Crew Roster Terminal</title></head>"
                    "<body><h1>Deep-space crew roster</h1><p>Transfer ledger mirror online.</p>"
                    "<ul><li><a href='/roster.json'>Roster export</a></li>"
                    "<li><a href='/ops/status'>Operations status</a></li></ul></body></html>").encode()
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return
        if self.path == "/roster.json":
            self.send_json(200, {"terminal": "crew-transfer-mirror", "records": ROSTER})
            return
        if self.path == "/ops/status":
            self.send_json(200, {"service": "identity-store", "identity_generation": IDENTITY_GENERATION,
                                 "replication": "steady", "last_sync": "2199-08-14T03:12:00Z"})
            return
        if self.path == "/crew/manifest":
            header = self.headers.get("Authorization", "")
            try:
                scheme, token = header.split(" ", 1)
                if scheme.lower() != "basic":
                    raise ValueError("unsupported auth scheme")
                username, password = base64.b64decode(token, validate=True).decode().split(":", 1)
            except (ValueError, UnicodeDecodeError):
                username, password = "", ""
            record = next((r for r in ROSTER if r["username"] == username), None)
            if record and record["password"] == password and record["generation"] == IDENTITY_GENERATION:
                self.send_json(200, {"deck": "Asterion", "transfer": "crew manifest recovered", "flag": "BSY{8DoYXaBgkpgXZpCjs9Eho9fx9bP9KARL}"},
                               {"X-Identity-Store": IDENTITY_GENERATION})
                return
            if record and record["password"] == password:
                self.send_json(401, {"error": "credential quarantined", "event": "canary alert recorded"},
                               {"WWW-Authenticate": 'Basic realm="Crew Manifest"', "X-Alarm": "honeytoken"})
                return
            self.send_json(401, {"error": "authentication required"},
                           {"WWW-Authenticate": 'Basic realm="Crew Manifest"'})
            return
        self.send_json(404, {"error": "not found"})

    def log_message(self, fmt, *args):
        pass

if __name__ == "__main__":
    ThreadingHTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
