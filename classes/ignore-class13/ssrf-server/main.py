#!/usr/bin/env python3
import http.server
import socketserver
import urllib.request
from urllib.parse import urlparse, parse_qs

PORT = 80

BANK_HTML = b"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Monster Bank</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet">

    <style>
        body { background-color: #f4f6f8; }
        .hero {
            background: linear-gradient(135deg, #2c3e50, #4ca1af);
            color: white;
            padding: 40px;
            border-radius: 12px;
            margin-bottom: 30px;
        }
        iframe {
            width: 100%;
            height: 600px;
            border: 1px solid #ccc;
            border-radius: 8px;
            background: white;
        }
    </style>
</head>
<body class="container my-4">

<div class="hero">
    <h1>Monster Bank</h1>
    <p class="lead">Secure banking. Trusted infrastructure. Questionable backend.</p>
</div>

<div class="card mb-4">
    <div class="card-body">
        <h5 class="card-title">Security & Financial News</h5>
        <p class="card-text">
            Our backend securely fetches trusted news sources for our customers.
        </p>

        <form method="GET" action="/">
            <label class="form-label">News Server</label>
            <input class="form-control mb-3"
                   name="url"
                   value="https://thehackernews.com/">
            <button class="btn btn-primary">Load News</button>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-body">
        <h5 class="card-title">News Preview</h5>
        <iframe id="newsFrame"></iframe>
    </div>
</div>

<script>
    const params = new URLSearchParams(window.location.search);
    if (params.has("url")) {
        document.getElementById("newsFrame").src =
            "/?url=" + encodeURIComponent(params.get("url"));
    }
</script>

</body>
</html>
"""

class SSRFHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        parsed = urlparse(self.path)
        params = parse_qs(parsed.query)

        # SSRF endpoint (intentionally vulnerable)
        if "url" in params:
            target_url = params["url"][0]
            self.send_response(200)
            self.end_headers()
            try:
                with urllib.request.urlopen(target_url) as response:
                    self.wfile.write(response.read())
            except Exception as e:
                self.wfile.write(f"Error fetching URL: {e}".encode())
            return

        # Default homepage
        self.send_response(200)
        self.send_header("Content-Type", "text/html")
        self.end_headers()
        self.wfile.write(BANK_HTML)


with socketserver.TCPServer(("", PORT), SSRFHandler) as httpd:
    print(f"Serving Monster Bank (SSRF vulnerable) on port {PORT}")
    httpd.serve_forever()
