from http.server import HTTPServer, BaseHTTPRequestHandler
import urllib.parse

class Server(BaseHTTPRequestHandler):
    def do_GET(self):
        path = urllib.parse.urlparse(self.path).path
        
        if path == "/" or path == "/index.html" or not path:
            # If no file is requested, send usage instructions how to use the server
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            instruction = "Please specify a quote file to read in the URL path. Options are: ['asimov.txt', 'einstein.txt', 'jobs.txt']\n"
            self.wfile.write(instruction.encode())
            
        else:
            try:
                with open(path, 'r') as f:
                    content = f.read()
                
                self.send_response(200)
                self.send_header('Content-type', 'text/plain')
                self.end_headers()
                self.wfile.write(content.encode())

            except FileNotFoundError:
                # If the file is not found, send a 404 Not Found response
                self.send_error(404, "File Not Found: %s" % self.path)
            
            except Exception:
                self.send_error(500, "Internal Server Error")


if __name__ == '__main__':
    port = 8080
    server_address = ('', port)
    httpd = HTTPServer(server_address, Server)
    print(f"Serving HTTP on port {port}...")
    httpd.serve_forever()
