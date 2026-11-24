import hashlib
import logging
import os
from pathlib import Path

from pyftpdlib.authorizers import AuthenticationFailed, DummyAuthorizer
from pyftpdlib.handlers import FTPHandler
from pyftpdlib.servers import FTPServer

ROOT = Path('/srv/relay')
PUBLIC = ROOT / 'public'
PRIVATE = ROOT / 'relay-home' / 'dispatch'
ACCOUNT = 'relay'
REAL_PASSWORD = 'orbit-lattice-7'
CANDIDATES = [
    'orbit-lattice-7',
    'violet-comet-31',
    'cobalt-signal-88',
    'night-shift-204',
]
FLAG = "BSY{Y7HHYvdzrVRgevNbxvzXVDLC8449Ucau}"

logging.basicConfig(level=logging.INFO, format='%(asctime)s %(message)s')
PUBLIC.mkdir(parents=True, exist_ok=True)
PRIVATE.mkdir(parents=True, exist_ok=True)
(PUBLIC / 'crew-access.txt').write_text(
    'RELAY ARCHIVE / crew access recovery\n'
    'Account: relay\n'
    'Candidate passphrases recovered from the collective mirror:\n'
    + ''.join(f'- {candidate}\n' for candidate in CANDIDATES),
    encoding='utf-8',
)
(PUBLIC / 'recovery-notes.ini').write_text(
    '[archive-recovery]\n'
    'account = relay\n'
    'credential_fingerprint = sha256:'
    + hashlib.sha256(REAL_PASSWORD.encode()).hexdigest()
    + '\nsource = node recovery snapshot\n',
    encoding='utf-8',
)
(PRIVATE / 'dispatch.txt').write_text(FLAG + '\n', encoding='utf-8')


class RelayAuthorizer(DummyAuthorizer):
    def validate_authentication(self, username, password, handler):
        if username == ACCOUNT and password in CANDIDATES and password != REAL_PASSWORD:
            logging.warning('HONEYWORD ACTIVATED account=%s remote=%s', username, handler.remote_ip)
            raise AuthenticationFailed('Credential tripwire activated; access denied and session recorded.')
        return super().validate_authentication(username, password, handler)


authorizer = RelayAuthorizer()
authorizer.add_anonymous(str(PUBLIC), perm='elr')
authorizer.add_user(ACCOUNT, REAL_PASSWORD, str(ROOT / 'relay-home'), perm='elr')

handler = FTPHandler
authorizer.banner = 'Relay Archive node 7.4 - collective mirror service'
handler.authorizer = authorizer
handler.banner = 'Relay Archive node 7.4 - collective mirror service'

server = FTPServer(('0.0.0.0', 21), handler)
server.serve_forever()
