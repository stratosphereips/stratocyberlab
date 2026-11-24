import base64
import socketserver

FLAG = "BSY{zhQ1jJLP5OqyPn4TIEedQCvRNYBvLa0g}"

# Public access artifacts include both real credentials and honeywords.
ARTIFACTS = {
    "orbit": "vector-17",
    "mira": "lunar-echo",
    "patch": "rootbeer-88",
    "relay": "blue-screen-6",
}
REAL_USERS = {"mira": "lunar-echo"}


class SMTPHandler(socketserver.StreamRequestHandler):
    def reply(self, message):
        self.wfile.write((message + "\r\n").encode())
        self.wfile.flush()

    def handle(self):
        self.reply("220 Echo BBS relay ESMTP ready")
        authenticated = False
        while True:
            raw = self.rfile.readline()
            if not raw:
                return
            line = raw.decode("utf-8", "replace").strip()
            if not line:
                continue
            pieces = line.split(None, 1)
            command = pieces[0].upper()
            argument = pieces[1] if len(pieces) > 1 else ""

            if command in ("EHLO", "HELO"):
                self.reply("250-echo-bbs")
                self.reply("250-AUTH PLAIN")
                self.reply("250 HELP VRFY EXPN")
            elif command == "HELP":
                self.reply("214 SMTP relay; available: EXPN VRFY AUTH MAIL RCPT DATA QUIT")
            elif command == "EXPN":
                if argument.lower() != "crew":
                    self.reply("550 no such list")
                    continue
                records = list(ARTIFACTS.items())
                for index, (username, password) in enumerate(records):
                    sep = " " if index == len(records) - 1 else "-"
                    self.reply(f"250{sep}{username}:{password}")
            elif command == "VRFY":
                username = argument.strip().strip("<>").split("@", 1)[0].lower()
                if username in REAL_USERS:
                    self.reply(f"250 {username} <{username}@echo.invalid>")
                else:
                    self.reply("550 mailbox unavailable")
            elif command == "AUTH":
                auth_parts = argument.split()
                if not auth_parts or auth_parts[0].upper() != "PLAIN":
                    self.reply("504 unsupported authentication mechanism")
                    continue
                if len(auth_parts) < 2:
                    self.reply("334")
                    encoded = self.rfile.readline().decode("utf-8", "replace").strip()
                else:
                    encoded = auth_parts[1]
                try:
                    fields = base64.b64decode(encoded).decode().split("\x00")
                    username, password = fields[-2], fields[-1]
                except Exception:
                    username, password = "", ""
                authenticated = REAL_USERS.get(username) == password
                if authenticated:
                    self.reply("235 2.7.0 authentication successful")
                else:
                    self.reply("535 5.7.8 authentication failed; access event recorded")
            elif command == "MAIL":
                self.reply("250 sender accepted")
            elif command == "RCPT":
                self.reply("250 recipient accepted")
            elif command == "DATA":
                self.reply("354 end message with <CRLF>.<CRLF>")
                while True:
                    body_line = self.rfile.readline()
                    if not body_line or body_line.strip() == b".":
                        break
                if authenticated:
                    self.reply("250 archive broadcast: " + FLAG)
                else:
                    self.reply("250 message queued for review")
            elif command == "RSET":
                authenticated = False
                self.reply("250 reset")
            elif command == "NOOP":
                self.reply("250 ok")
            elif command == "QUIT":
                self.reply("221 closing connection")
                return
            else:
                self.reply("502 command not implemented")


class ThreadedSMTPServer(socketserver.ThreadingTCPServer):
    allow_reuse_address = True
    daemon_threads = True


if __name__ == "__main__":
    with ThreadedSMTPServer(("0.0.0.0", 25), SMTPHandler) as server:
        server.serve_forever()
