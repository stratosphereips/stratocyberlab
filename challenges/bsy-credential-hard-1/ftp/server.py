from pyftpdlib.authorizers import DummyAuthorizer
from pyftpdlib.handlers import FTPHandler
from pyftpdlib.servers import FTPServer

authorizer = DummyAuthorizer()
authorizer.add_anonymous("/srv/ftp", perm="elr")
handler = FTPHandler
handler.authorizer = authorizer
FTPServer(("0.0.0.0", 21), handler).serve_forever()
