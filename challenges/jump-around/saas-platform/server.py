from http.server import BaseHTTPRequestHandler, HTTPServer

class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write(b'OK 200')

    def do_POST(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write(b'OK 200')

if __name__ == '__main__':
    server_address = ('', 80)  # Serve on all interfaces, port 80
    httpd = HTTPServer(server_address, SimpleHTTPRequestHandler)
    print('Server running on port 80...')
    httpd.serve_forever()
