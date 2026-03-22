import json
import signal
import subprocess
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlsplit

HOST = '0.0.0.0'
PORT = 9001

INDEX_HTML = """<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Observability Plugin</title>
    <style>
      body {
        margin: 0;
        padding: 24px;
        font-family: sans-serif;
        background: #f6f7fb;
        color: #18212f;
      }

      main {
        max-width: 720px;
        margin: 0 auto;
      }

      .panel {
        background: #ffffff;
        border: 1px solid #d6dbe6;
        border-radius: 12px;
        padding: 20px;
        box-shadow: 0 10px 30px rgba(24, 33, 47, 0.08);
      }

      button {
        border: 0;
        border-radius: 999px;
        background: #1463ff;
        color: #ffffff;
        padding: 10px 18px;
        cursor: pointer;
      }

      ul {
        padding-left: 20px;
      }

      code {
        background: #eff3fb;
        padding: 2px 6px;
        border-radius: 6px;
      }

      #status {
        color: #566171;
      }
    </style>
  </head>
  <body>
    <main>
      <div class="panel">
        <h1>Observability Plugin</h1>
        <p>This reference plugin lists running Docker containers whose names start with <code>scl-</code>.</p>
        <button id="refresh" type="button">Refresh</button>
        <p id="status">Press Refresh to query the Docker daemon.</p>
        <ul id="containers"></ul>
      </div>
    </main>
    <script>
      const status = document.getElementById('status');
      const containers = document.getElementById('containers');
      const refreshButton = document.getElementById('refresh');

      async function refreshContainers() {
        status.textContent = 'Loading containers...';
        containers.innerHTML = '';

        try {
          const response = await fetch('actions.json', { cache: 'no-store' });
          const data = await response.json();

          if (!response.ok) {
            throw new Error(data.error || 'Request failed');
          }

          if (data.containers.length === 0) {
            status.textContent = 'No running containers with the scl- prefix were found.';
            return;
          }

          status.textContent = `Found ${data.containers.length} running container(s).`;
          for (const container of data.containers) {
            const item = document.createElement('li');
            item.textContent = container;
            containers.appendChild(item);
          }
        } catch (error) {
          status.textContent = `Error: ${error.message}`;
        }
      }

      refreshButton.addEventListener('click', refreshContainers);
    </script>
  </body>
</html>
"""

SERVER = None


def list_scl_containers():
    result = subprocess.run(
        ['docker', 'ps', '--format', '{{.Names}}'],
        capture_output=True,
        text=True,
        check=True,
    )
    containers = []
    for line in result.stdout.splitlines():
        name = line.strip()
        if name.startswith('scl-'):
            containers.append(name)
    return containers


class ObservabilityHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed = urlsplit(self.path)
        if parsed.path == '/':
            self.send_html(INDEX_HTML)
            return

        if parsed.path == '/actions.json':
            try:
                payload = {'containers': list_scl_containers()}
                self.send_json(200, payload)
            except subprocess.CalledProcessError as exc:
                self.send_json(500, {
                    'error': exc.stderr.strip() or exc.stdout.strip() or 'docker ps failed',
                })
            return

        self.send_json(404, {'error': 'Not found'})

    def log_message(self, format_string, *args):
        print(format_string % args)

    def send_html(self, body):
        encoded = body.encode('utf8')
        self.send_response(200)
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        self.send_header('Content-Length', str(len(encoded)))
        self.end_headers()
        self.wfile.write(encoded)

    def send_json(self, status_code, payload):
        encoded = json.dumps(payload).encode('utf8')
        self.send_response(status_code)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Content-Length', str(len(encoded)))
        self.end_headers()
        self.wfile.write(encoded)


def handle_shutdown(signum, _frame):
    print(f"Received signal {signum}, shutting down observability plugin.")
    if SERVER is not None:
        threading.Thread(target=SERVER.shutdown, daemon=True).start()


if __name__ == '__main__':
    SERVER = ThreadingHTTPServer((HOST, PORT), ObservabilityHandler)
    signal.signal(signal.SIGINT, handle_shutdown)
    signal.signal(signal.SIGTERM, handle_shutdown)
    print(f"Observability plugin listening on http://{HOST}:{PORT}")
    try:
        SERVER.serve_forever()
    finally:
        SERVER.server_close()
        print('Observability plugin stopped.')
