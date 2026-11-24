import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse

FLAG = "BSY{C7XvQCyHdZodWc94IbhTQUSZThdz6BNK}"

ACCOUNTS = [
    {"id": "ledger-ops", "role": "settlement analyst"},
    {"id": "bluejay-recon", "role": "reconciliation analyst"},
    {"id": "orbit-compliance", "role": "compliance analyst"},
]

KEY_CARDS = [
    {"owner": "redshift-clerk", "access_key": "rk_7d2a91c4"},
    {"owner": "ledger-ops", "access_key": "rk_4b8e13f0"},
    {"owner": "phantom-settlement", "access_key": "rk_90c6a2e7"},
    {"owner": "night-window", "access_key": "rk_1f5d83ab"},
]

class Handler(BaseHTTPRequestHandler):
    def send_json(self, status, value):
        body = json.dumps(value).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        path = urlparse(self.path).path
        if path == "/health":
            return self.send_json(200, {"status": "ok"})
        if path == "/":
            return self.send_json(200, {
                "service": "Orbit Bank public API",
                "notice": "Settlement network interface",
                "catalogues": ["/v1/accounts", "/v1/key-cards"],
                "session_service": "/v1/session",
            })
        if path == "/v1/accounts":
            return self.send_json(200, {"accounts": ACCOUNTS})
        if path == "/v1/key-cards":
            return self.send_json(200, {"key_cards": KEY_CARDS})
        return self.send_json(404, {"error": "resource unavailable"})

    def do_POST(self):
        if urlparse(self.path).path != "/v1/session":
            return self.send_json(404, {"error": "resource unavailable"})
        try:
            size = int(self.headers.get("Content-Length", "0"))
            data = json.loads(self.rfile.read(size))
        except (ValueError, json.JSONDecodeError):
            return self.send_json(400, {"error": "invalid request"})

        owner = data.get("owner")
        access_key = data.get("access_key")
        for card in KEY_CARDS:
            if card["owner"] == owner and card["access_key"] == access_key:
                if owner == "ledger-ops":
                    return self.send_json(200, {"status": "session established", "audit_record": FLAG})
                return self.send_json(403, {
                    "status": "credential quarantined",
                    "message": "A watchdesk review has been queued.",
                })
        return self.send_json(401, {"status": "access denied"})

    def log_message(self, format, *args):
        pass

if __name__ == "__main__":
    ThreadingHTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
