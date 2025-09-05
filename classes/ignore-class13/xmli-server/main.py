#!/usr/bin/env python3

# requires: pip install lxml

import socketserver
from http.server import SimpleHTTPRequestHandler
from lxml import etree

PORT = 80


class XMLInjectionVulnerableServer(SimpleHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)

        try:
            # Parse the XML data (this is where the vulnerability lies)
            parser = etree.XMLParser(resolve_entities=True)
            # Access the underlying libxml2 parsing context
            tree = etree.fromstring(post_data, parser)
            response = "Received: " + tree.find('data').text
        except etree.XMLSyntaxError as e:
            response = f"Error parsing XML: {e}"

        # Send HTTP response
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        self.wfile.write(response.encode('utf-8'))


with socketserver.TCPServer(("", PORT), XMLInjectionVulnerableServer) as httpd:
    print(f"Serving XML injection vulnerable server on port {PORT}")
    httpd.serve_forever()
