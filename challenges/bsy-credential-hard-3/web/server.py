from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer


class BoardHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory="/srv/site", **kwargs)


ThreadingHTTPServer(("0.0.0.0", 8080), BoardHandler).serve_forever()
