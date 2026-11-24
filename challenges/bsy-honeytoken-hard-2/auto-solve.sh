#!/bin/sh
set -eu
python3 - <<'PY'
import csv
import ftplib
import io
import json
import re
import subprocess

host = "172.20.0.141"
ftp = ftplib.FTP(host, timeout=8)
ftp.login()

def read_file(name):
    data = bytearray()
    ftp.retrbinary("RETR " + name, data.extend)
    return data.decode()

cards = list(csv.DictReader(io.StringIO(read_file("keycards.csv"))))
ledger = list(csv.DictReader(io.StringIO(read_file("settlement-ledger.csv"))))
verified = []
for card in cards:
    matches = [row for row in ledger if row["card_serial"] == card["card_serial"] and row["principal"] == card["login"]]
    if matches:
        verified.append(card)
if len(verified) != 1:
    raise SystemExit("Expected exactly one cross-source match")
card = verified[0]
ftp.quit()
ftp = ftplib.FTP(host, timeout=8)
ftp.login(card["login"], card["passphrase"])
proof = bytearray()
ftp.retrbinary("RETR settlement.txt", proof.extend)
match = re.search(rb"BSY\{[^}\r\n]+\}", proof)
if not match:
    raise SystemExit("Settlement record did not contain a flag")
flag = match.group(0).decode()
subprocess.run([
    "curl", "-s", "http://172.20.0.3/api/challenges/submit", "-X", "POST",
    "-H", "Content-Type: application/json",
    "--data-binary", json.dumps({"challenge_id": "scl-challenge-frame-fd1315", "task_id": "task1", "flag": flag})
], check=True)
PY
