import logging
from pyftpdlib.authorizers import DummyAuthorizer
from pyftpdlib.handlers import FTPHandler
from pyftpdlib.servers import FTPServer

REAL_USER = "orbit"
REAL_PASSWORD = "starlight-archive-27"
DECOYS = {
    "echo": "vector-rain-13",
    "glitch": "neon-static-88",
    "proxy": "midnight-cache-42",
}

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")

class RangeFTPHandler(FTPHandler):
    def ftp_PASS(self, line):
        password = line.strip()
        if DECOYS.get(self.username) == password:
            logging.warning("ALERT honeytoken activation: account=%s source=%s", self.username, self.remote_ip)
            self.respond("530 Login incorrect.")
            return
        return super().ftp_PASS(line)

authorizer = DummyAuthorizer()
authorizer.add_anonymous("/srv/ftp/public", perm="elr")
authorizer.add_user(REAL_USER, REAL_PASSWORD, "/srv/ftp/real", perm="elr")
RangeFTPHandler.authorizer = authorizer
RangeFTPHandler.passive_ports = range(30000, 30010)

server = FTPServer(("0.0.0.0", 21), RangeFTPHandler)
server.serve_forever()
