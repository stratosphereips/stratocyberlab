#!/usr/bin/env python3
import os
import socket
import socketserver
import subprocess
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, HTTPServer

REDIS_PORT = 2525
RECORD_KEY = "radio:night-transmission"


def redis_command(sock, *parts):
    payload = f"*{len(parts)}\r\n".encode()
    for part in parts:
        encoded = str(part).encode()
        payload += f"${len(encoded)}\r\n".encode() + encoded + b"\r\n"
    sock.sendall(payload)
    return sock.recv(4096)


class BoardHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        body = b"ACCESS DENIED - broadcast control requires an operator token.\n"
        self.send_response(403)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *_args):
        pass


def run_http():
    HTTPServer(("0.0.0.0", 6379), BoardHandler).serve_forever()


class VNCHandler(socketserver.BaseRequestHandler):
    def handle(self):
        self.request.settimeout(3)
        try:
            self.request.sendall(b"RFB 003.008\r\n")
            version = self.request.recv(12)
            if version.startswith(b"RFB "):
                self.request.sendall(b"\x01\x01")
                self.request.recv(1)
                self.request.sendall(b"\x00\x00\x00\x0cAccess denied")
        except (OSError, TimeoutError):
            pass


class VNCServer(socketserver.ThreadingTCPServer):
    allow_reuse_address = True
    daemon_threads = True


def run_vnc():
    VNCServer(("0.0.0.0", 443), VNCHandler).serve_forever()


def start_redis():
    proc = subprocess.Popen([
        "redis-server", "--bind", "0.0.0.0", "--port", str(REDIS_PORT),
        "--protected-mode", "no", "--save", "", "--appendonly", "no"
    ])
    try:
        for _ in range(100):
            if proc.poll() is not None:
                raise RuntimeError("Redis exited during startup")
            try:
                with socket.create_connection(("127.0.0.1", REDIS_PORT), timeout=0.5) as conn:
                    if redis_command(conn, "PING").startswith(b"+PONG"):
                        break
            except OSError:
                time.sleep(0.1)
        else:
            raise RuntimeError("Redis did not become ready")

        with socket.create_connection(("127.0.0.1", REDIS_PORT), timeout=2) as conn:
            reply = redis_command(conn, "SET", RECORD_KEY, os.environ["FLAG"])
            if not reply.startswith(b"+OK"):
                raise RuntimeError("Could not load the broadcast record")
        return proc
    except Exception:
        proc.terminate()
        proc.wait()
        raise


def run_all():
    proc = start_redis()
    threading.Thread(target=run_http, daemon=True).start()
    threading.Thread(target=run_vnc, daemon=True).start()
    try:
        proc.wait()
    finally:
        if proc.poll() is None:
            proc.terminate()
            proc.wait()


if __name__ == "__main__":
    if sys.argv[1] != "all":
        raise SystemExit("unknown service role")
    run_all()
