#!/usr/bin/env python3
"""
Minimal telnet honeypot tailored for the anyone-home challenge.
It accepts one of the default credentials and returns plausible command output
so the bundled attacker proceeds with payload deployment.
"""

from __future__ import annotations

import argparse
import sys
import logging
import socket
import socketserver
import threading
from datetime import datetime, timezone
from typing import Iterable, List, Optional

# Telnet control bytes.
IAC = 255  # "Interpret As Command"
DO = 253
DONT = 254
WILL = 251
WONT = 252
SB = 250
SE = 240

DEFAULT_BIND = "0.0.0.0"
DEFAULT_PORT = 23


class TelnetSessionHandler(socketserver.BaseRequestHandler):
    """Single telnet session state machine."""

    VALID_CREDENTIALS = {
        ("root", "toor"),
        ("root", "administrator"),
        ("administrator", "123456"),
    }

    PROMPT = "# "
    SOCKET_TIMEOUT = 60

    def setup(self) -> None:
        self.request.settimeout(self.SOCKET_TIMEOUT)
        self._lock = threading.Lock()
        self._alive = True
        self._pending_lf = False

    def handle(self) -> None:
        logging.info("Connection from %s:%s", *self.client_address)
        try:
            if not self._perform_login():
                return
            while self._alive:
                line = self._readline()
                if line is None:
                    break
                response = self._handle_command(line)
                if response:
                    self._send_lines(response)
                if self._alive:
                    self._send_text(self.PROMPT)
        except Exception as exc:  # pragma: no cover - defensive logging
            logging.exception("Session error: %s", exc)
        finally:
            logging.info("Session from %s:%s closed", *self.client_address)

    def finish(self) -> None:
        try:
            self.request.shutdown(socket.SHUT_RDWR)
        except OSError:
            pass
        self.request.close()

    # --- transport helpers -------------------------------------------------

    def _send_text(self, text: str) -> None:
        if not text:
            return
        with self._lock:
            self.request.sendall(text.encode("utf-8", errors="ignore"))

    def _send_line(self, line: str = "") -> None:
        self._send_text(line + "\r\n")

    def _send_lines(self, lines: Iterable[str]) -> None:
        for line in lines:
            self._send_line(line)

    def _perform_login(self) -> bool:
        for _attempt in range(3):
            self._send_text("login: ")
            username = self._readline()
            if username is None:
                return False
            self._send_text("password: ")
            password = self._readline()
            if password is None:
                return False
            if self._check_credentials(username, password):
                self._send_line("")
                self._send_line("Welcome to Stratocast honeypot.")
                self._send_line("Type 'help' to get started.")
                self._send_text(self.PROMPT)
                return True
            self._send_line("")
            self._send_line("Login incorrect")
        return False

    def _check_credentials(self, username: str, password: str) -> bool:
        uname = username.strip()
        pwd = password.strip()
        return (uname, pwd) in self.VALID_CREDENTIALS

    def _readline(self) -> Optional[str]:
        buffer = bytearray()
        while True:
            try:
                chunk = self.request.recv(1)
            except socket.timeout:
                return None
            if not chunk:
                return None
            byte = chunk[0]
            if byte == IAC:
                self._handle_iac()
                continue
            if byte in (10, 13):  # NL or CR
                if byte == 13:
                    self._pending_lf = True
                    self._swallow_lf()
                else:
                    self._pending_lf = False
                break
            buffer.append(byte)
        try:
            return buffer.decode("utf-8").strip()
        except UnicodeDecodeError:
            return buffer.decode("ascii", errors="ignore").strip()

    def _swallow_lf(self) -> None:
        if not self._pending_lf:
            return
        # Try to consume a trailing LF after CR without blocking the session.
        try:
            self.request.settimeout(0.05)
            peek = self.request.recv(1, socket.MSG_PEEK)
            if peek == b"\n":
                self.request.recv(1)
        except (BlockingIOError, socket.timeout, OSError):
            pass
        finally:
            self.request.settimeout(self.SOCKET_TIMEOUT)
            self._pending_lf = False

    def _handle_iac(self) -> None:
        try:
            cmd = self.request.recv(1)
            if not cmd:
                return
            code = cmd[0]
            if code in (DO, DONT, WILL, WONT):
                opt = self.request.recv(1)
                if not opt:
                    return
                # Politely refuse all option negotiation.
                if code in (DO, DONT):
                    response = bytes([IAC, WONT, opt[0]])
                else:
                    response = bytes([IAC, DONT, opt[0]])
                self.request.sendall(response)
            elif code == SB:
                # Drain until IAC SE.
                while True:
                    data = self.request.recv(1)
                    if not data:
                        break
                    if data[0] == IAC:
                        end = self.request.recv(1)
                        if end and end[0] == SE:
                            break
            else:
                # Ignore any other control sequence.
                return
        except OSError:
            return

    # --- command handling ---------------------------------------------------

    def _handle_command(self, raw_command: str) -> List[str]:
        if not raw_command:
            return []
        logging.info("handling command %s", raw_command)

        commands = [segment.strip() for segment in raw_command.split(";") if segment.strip()]
        responses: List[str] = []

        for command in commands:
            if command.lower() in {"exit", "logout"}:
                self._alive = False
                responses.append("logout")
                break
            elif command.startswith("echo "):
                responses.append(self._handle_echo(command))
            elif command.startswith("uname"):
                responses.append(self._fake_uname())
            elif command == "ps":
                responses.extend(self._fake_ps())
            elif command == "date":
                responses.append(self._fake_date())
            elif command.startswith("wget "):
                responses.extend(self._fake_wget(command))

            elif command.startswith("chmod "):
                # Silent success for chmod commands.
                continue
            elif command == "help":
                responses.extend(self._fake_help())
            else:
                generic = self._generic_ok(command)
                if generic:
                    responses.append(generic)
        return responses

    def _handle_echo(self, command: str) -> str:
        return command[5:].lstrip()

    def _fake_uname(self) -> str:
        return "Linux strato-hp 5.10.0-21-amd64 #1 SMP Debian 5.10.178 x86_64 GNU/Linux"

    def _fake_ps(self) -> List[str]:
        return [
            "  PID TTY          TIME CMD",
            "    1 ?        00:00:01 init",
            "   12 ?        00:00:00 python3",
            "   47 ?        00:00:00 sshd",
            "   88 ?        00:00:00 busybox",
        ]

    def _fake_date(self) -> str:
        now = datetime.now(timezone.utc)
        return now.strftime("%a %b %d %H:%M:%S UTC %Y")

    def _fake_wget(self, command: str) -> List[str]:
        timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")
        target = command.split(" ", 1)[1]
        return [
            f"--{timestamp}--  {target}",
            "Resolving 172.20.0.46 (172.20.0.46)... 172.20.0.46",
            "Connecting to 172.20.0.46 (172.20.0.46)|172.20.0.46|:8080... connected.",
            "HTTP request sent, awaiting response... 200 OK",
            "Length: 512 [text/plain]",
            "Saving to: ‘/tmp/d’",
            "",
            "/tmp/d             100%[===================>]   512  --.-KB/s    in 0s",
            "",
            f"{timestamp} (12.3 MB/s) - ‘/tmp/d’ saved [512/512]",
        ]

    def _fake_help(self) -> List[str]:
        return [
            "Built-in commands:",
            "  help        Show this help message",
            "  exit        Close the session",
        ]

    def _generic_ok(self, command: str) -> Optional[str]:
        return None


class ThreadedTCPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    allow_reuse_address = True
    daemon_threads = True


def serve(host: str, port: int) -> None:
    with ThreadedTCPServer((host, port), TelnetSessionHandler) as server:
        logging.info("Telnet honeypot listening on %s:%s", host, port)
        try:
            server.serve_forever()
        except KeyboardInterrupt:
            logging.info("Shutting down honeypot.")


def main() -> None:
    parser = argparse.ArgumentParser(description="Simple telnet honeypot for the anyone-home challenge.")
    parser.add_argument("--host", default=DEFAULT_BIND, help="Address to bind to (default: 0.0.0.0)")
    parser.add_argument("--port", type=int, default=DEFAULT_PORT, help="Port to listen on (default: 23)")
    parser.add_argument("--log-level", default="INFO", help="Logging verbosity (default: INFO)")
    args = parser.parse_args()

    logging.basicConfig(
        level=getattr(logging, args.log_level.upper(), logging.INFO),
        format="%(asctime)s %(levelname)s %(message)s",
    )
    serve(args.host, args.port)


if __name__ == "__main__":
    main()
