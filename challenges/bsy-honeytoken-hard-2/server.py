import logging
from pyftpdlib.authorizers import DummyAuthorizer
from pyftpdlib.handlers import FTPHandler
from pyftpdlib.servers import FTPServer

DECOY_USERS = {"lunar_cashier", "mint_fox", "vault_drift"}
REAL_USER = "ledger_owl"
REAL_PASSWORD = "orbit-8f2c-velvet"

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(message)s")
authorizer = DummyAuthorizer()
authorizer.add_anonymous("/srv/ftp/pub", perm="elr")
authorizer.add_user(REAL_USER, REAL_PASSWORD, "/srv/ftp/real", perm="elr")

class LedgerHandler(FTPHandler):
    def ftp_PASS(self, line):
        if self.username in DECOY_USERS:
            logging.warning("HONEYTOKEN alarm: rejected decoy account %s", self.username)
            self.respond("530 Access denied; security event recorded.")
            return
        return super().ftp_PASS(line)

LedgerHandler.authorizer = authorizer
LedgerHandler.passive_ports = range(30000, 30011)
server = FTPServer(("0.0.0.0", 21), LedgerHandler)
server.serve_forever()
