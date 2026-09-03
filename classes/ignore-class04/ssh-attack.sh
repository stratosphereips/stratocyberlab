#!/usr/bin/env bash
# ssh-attack.ssh
# Repeatedly attempts SSH with random credentials to generate auth.log entries on the target.

# --- configurable -------------------------------------------------------------

TARGET_IP="${1:-172.20.0.2}"

# Five sample username:password pairs (edit to taste)
CREDENTIALS=(
  "alice:Spring2025!"
  "bob:Password123"
  "student:letmein"
  "guest:guest"
  "admin:admin123"
  "root:ByteThem123"
)

# Path to sshpass (required to provide the password non-interactively)
SSHPASS_BIN="${SSHPASS_BIN:-sshpass}"

# SSH options to keep things quiet and quick
SSH_OPTS=(
  -o StrictHostKeyChecking=no
  -o UserKnownHostsFile=/dev/null
  -o PreferredAuthentications=password
  -o PubkeyAuthentication=no
  -o NumberOfPasswordPrompts=1
  -o ConnectTimeout=5
  -o LogLevel=ERROR
)

SLEEP_SECONDS=30

# --- end configurable ---------------------------------------------------------

if ! command -v "$SSHPASS_BIN" >/dev/null 2>&1; then
    echo "[-] sshpass not found. On Debian/Ubuntu: sudo apt-get update && sudo apt-get install -y sshpass" >&2
  exit 1
fi

echo "[*] Target: ${TARGET_IP}"
echo "[*] Attempts every ${SLEEP_SECONDS}s using ${#CREDENTIALS[@]} credential options."
echo "[*] Press Ctrl-C to stop."

# Clean exit on Ctrl-C
trap 'echo; echo "[*] Stopping..."; exit 0' INT

while :; do
  # Pick a random credential pair
  idx=$(( RANDOM % ${#CREDENTIALS[@]} ))
  pair="${CREDENTIALS[$idx]}"

  user="${pair%%:*}"
  pass="${pair#*:}"

  ts="$(date -Is)"
  echo "[${ts}] -> Trying ${user}@${TARGET_IP}"

  # Attempt SSH; success isn't required—either way the server will log it
  # Suppress stdout/stderr from remote command to keep local console tidy.
  $SSHPASS_BIN -p "$pass" ssh "${SSH_OPTS[@]}" "${user}@${TARGET_IP}" 'whoami' >/dev/null 2>&1
  rc=$?

  # Local feedback only (server-side logs are what students analyze)
  if [ $rc -eq 0 ]; then
    echo "[${ts}] <- SSH command SUCCESS (server should log a successful auth)."
  else
    echo "[${ts}] <- SSH command FAILED (server should log a failed password/invalid user)."
  fi

  sleep "$SLEEP_SECONDS"
done
