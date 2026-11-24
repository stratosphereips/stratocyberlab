from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import io
import tarfile

ROOT = Path('/srv/www')
ROOT.mkdir(parents=True, exist_ok=True)
(ROOT / 'index.html').write_text('''<!doctype html>
<html><head><title>Roster Deck / Ops Cache</title></head>
<body><h1>Roster Deck Ops Cache</h1>
<p>Auxiliary cache online. Nightly crew-operations archive:</p>
<ul><li><a href="crew-roster-nightly.tar.gz">crew-roster-nightly.tar.gz</a></li></ul>
<p>Navigation systems report a stale cache; consult the archived shift notes.</p>
</body></html>''')

archive = io.BytesIO()
with tarfile.open(fileobj=archive, mode='w:gz') as bundle:
    payload = b'''[crew-mail]
username=ensign
password=starboard-7
'''
    info = tarfile.TarInfo('shift-notes.ini')
    info.size = len(payload)
    bundle.addfile(info, io.BytesIO(payload))
(ROOT / 'crew-roster-nightly.tar.gz').write_bytes(archive.getvalue())

class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)

    def log_message(self, fmt, *args):
        pass

ThreadingHTTPServer(('0.0.0.0', 80), Handler).serve_forever()
