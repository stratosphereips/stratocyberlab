import os
from pathlib import Path

from pyftpdlib.authorizers import DummyAuthorizer
from pyftpdlib.handlers import FTPHandler
from pyftpdlib.servers import FTPServer

ROOT = Path("/srv/actuator")
report = ROOT / "maintenance" / "actuator-status.txt"
report.parent.mkdir(parents=True, exist_ok=True)
report.write_text("Actuator maintenance status: nominal\nRecovery token: BSY{qbyKNkRWvQZ4FWY0uBBgV8eVpvPCs77n}\n")

# The console's temporary operator account was left in its service greeting.
authorizer = DummyAuthorizer()
authorizer.add_user("servo", "servo-7", str(ROOT), perm="elr")

class ActuatorHandler(FTPHandler):
    authorizer = authorizer
    banner = "StratoCyberLab robotics actuator console | operator access note: user=servo password=servo-7"
    passive_ports = range(30000, 30010)

server = FTPServer(("0.0.0.0", 21), ActuatorHandler)
server.serve_forever()
