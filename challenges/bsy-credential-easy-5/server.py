import os
from pyftpdlib.authorizers import DummyAuthorizer
from pyftpdlib.handlers import FTPHandler
from pyftpdlib.servers import FTPServer


class RelayHandler(FTPHandler):
    pass


authorizer = DummyAuthorizer()
authorizer.add_anonymous("/srv/ftp/public", perm="elr")
authorizer.add_user("relay archivist", "orbits-and-coffee", "/srv/ftp/private", perm="elr")
RelayHandler.authorizer = authorizer
RelayHandler.passive_ports = range(30000, 30010)
server = FTPServer(("0.0.0.0", int(os.environ.get("FTP_PORT", "2121"))), RelayHandler)
server.serve_forever()
