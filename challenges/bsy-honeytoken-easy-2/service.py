import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

# Candidate keys intentionally share the same shape. Some belong to ghost
# identities; the account roster below reflects the API's active records.
KEYS = [
    {"key": "ak_7c91e4a2d6f0", "account_id": "acct-1042"},
    {"key": "ak_2b5d8f13c9a6", "account_id": "acct-7719"},
    {"key": "ak_93a0c6e14b72", "account_id": "acct-3086"},
    {"key": "ak_f4182d7a0c35", "account_id": "acct-5521"}
]
ACCOUNTS = [
    {"account_id": "acct-1042", "status": "active"}
]
ACTIVE_KEY = "ak_7c91e4a2d6f0"
SESSIONS = {}

class Handler(BaseHTTPRequestHandler):
    def send_json(self, status, data):
        body = json.dumps(data).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/health":
            return self.send_json(200, {"status": "ok"})
        if self.path == "/":
            return self.send_json(200, {
                "service": "Asterion Treasury API",
                "api_version": "1",
                "resources": ["/v1/keys", "/v1/accounts", "/v1/session", "/v1/vault"]
            })
        if self.path == "/v1/keys":
            return self.send_json(200, {"keys": KEYS})
        if self.path == "/v1/accounts":
            return self.send_json(200, {"accounts": ACCOUNTS})
        if self.path == "/v1/vault":
            auth = self.headers.get("Authorization", "")
            token = auth.removeprefix("Bearer ")
            if SESSIONS.get(token) != "acct-1042":
                return self.send_json(403, {"error": "session required"})
            return self.send_json(200, {"vault": "Asterion reserve archive", "flag": "BSY{WPdTOcitWiOfdBYl5OgytuSg7pTUegLu}"})
        return self.send_json(404, {"error": "resource not found"})

    def do_POST(self):
        if self.path != "/v1/session":
            return self.send_json(404, {"error": "resource not found"})
        try:
            length = int(self.headers.get("Content-Length", "0"))
            data = json.loads(self.rfile.read(length))
        except (ValueError, json.JSONDecodeError):
            return self.send_json(400, {"error": "invalid request"})
        key = data.get("key", "")
        candidate = next((item for item in KEYS if item["key"] == key), None)
        if candidate is None:
            return self.send_json(401, {"error": "invalid credential"})
        if key != ACTIVE_KEY:
            return self.send_json(403, {
                "error": "access quarantined",
                "event": "risk signal forwarded to treasury monitoring"
            })
        token = "sess-asterion-1042"
        SESSIONS[token] = "acct-1042"
        return self.send_json(200, {"token": token})

    def log_message(self, fmt, *args):
        pass

ThreadingHTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
