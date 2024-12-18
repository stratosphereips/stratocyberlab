#!/usr/bin/env python3
import http.server
import socketserver
import urllib.request
from urllib.parse import urlparse, parse_qs

PORT = 80

class SSRFHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        query = urlparse(self.path).query
        params = parse_qs(query)

        if 'url' in params:
            target_url = params['url'][0]
            self.send_response(200)
            self.end_headers()
            try:
                with urllib.request.urlopen(target_url) as response:
                    content = response.read()
                    self.wfile.write(content)
            except Exception as e:
                self.wfile.write(f"Error fetching URL: {e}".encode())
        else:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b"Please provide a 'url' parameter.\n")


with socketserver.TCPServer(("", PORT), SSRFHandler) as httpd:
    print(f"Serving SSRF vulnerable server on port {PORT}")
    httpd.serve_forever()
