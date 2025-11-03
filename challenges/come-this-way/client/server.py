import http.server
import socketserver
from ftplib import FTP

# FTP server details
FTP_HOST = "172.20.0.72"
FTP_USER = "pepitto"
FTP_PASS = "Hard2GuessP@ssw0rd!"
FTP_FILE_PATH = "files/content.txt"

# Function to retrieve the content of the file from the FTP server
def fetch_file_content():
    try:
        with FTP(FTP_HOST) as ftp:
            ftp.login(FTP_USER, FTP_PASS)
            with open("content.txt", "wb") as f:
                ftp.retrbinary(f"RETR {FTP_FILE_PATH}", f.write)
        with open("content.txt", "r") as f:
            content = f.read()
        return content
    except Exception as e:
        return f"Error retrieving file: {e}"

# HTTP request handler
class SimpleHTTPRequestHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            # Fetch the content from the FTP server
            content = fetch_file_content()
            self.send_response(200)
            self.send_header("Content-type", "text/plain")
            self.end_headers()
            self.wfile.write(content.encode('utf-8'))
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"404 Not Found")

# Run the HTTP server
PORT = 80
BIND_IP = "172.20.0.71"
with socketserver.TCPServer((BIND_IP, PORT), SimpleHTTPRequestHandler) as httpd:
    print(f"Serving on port {BIND_IP}:{PORT}")
    httpd.serve_forever()