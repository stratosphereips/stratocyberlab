from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer


class StationHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory="/srv/www", **kwargs)


ThreadingHTTPServer(("0.0.0.0", 8080), StationHandler).serve_forever()
