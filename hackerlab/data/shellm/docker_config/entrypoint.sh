#!/bin/bash
# Entry point for the shelLMv2 SSH honeypot.
#
# Works identically in two contexts:
#   1. As a Docker image's ENTRYPOINT (the normal case for this repo).
#   2. Run directly inside an existing Linux container/host that doesn't
#      support nested Docker - just `bash docker_config/entrypoint.sh`.
# Both just need: Debian/Ubuntu with apt, and root.
set -e

APP_DIR="/opt/shellm"
HOST_KEY_DIR="$APP_DIR/docker_config/ssh_host_keys"
SSHD_CONFIG="$APP_DIR/docker_config/sshd_config"
MANAGED_USER_MARKER="$APP_DIR/docker_config/.managed_user"

# --- Load configuration from .env --------------------------------------
if [ -f "$APP_DIR/.env" ]; then
    set -a
    source "$APP_DIR/.env"
    set +a
fi

HONEYPOT_USER="${HONEYPOT_USER:-honeypot}"
HONEYPOT_PASSWORD="${HONEYPOT_PASSWORD:-changeme123}"
PORT="${PORT:-1397}"

if [ "$HONEYPOT_USER" = "root" ]; then
    echo "[shelLM] ERROR: HONEYPOT_USER cannot be 'root'. Pick a different name in .env." >&2
    exit 1
fi

# --- Install dependencies (skipped if already present, e.g. in the
#     Docker image where the Dockerfile already installed them) --------
if ! command -v sshd >/dev/null 2>&1 || ! python3 -c "import yaml" >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq
    apt-get install -y -qq --no-install-recommends openssh-server python3 python3-pip python3-venv
fi

pip3 install --no-cache-dir -q --break-system-packages -r "$APP_DIR/shellm_app/requirements.txt"

# --- Host keys (generated once, persisted across restarts if volume-mounted) ---
mkdir -p "$HOST_KEY_DIR"
[ -f "$HOST_KEY_DIR/ssh_host_rsa_key" ] || ssh-keygen -q -t rsa -b 4096 -f "$HOST_KEY_DIR/ssh_host_rsa_key" -N ""
[ -f "$HOST_KEY_DIR/ssh_host_ed25519_key" ] || ssh-keygen -q -t ed25519 -f "$HOST_KEY_DIR/ssh_host_ed25519_key" -N ""

# --- Honeypot login user (this is the account attackers/classmates use -
#     it only ever reaches the fake shell via ForceCommand, never a real one) ---
#
# Safety: if HONEYPOT_USER already exists, only touch (reset the password of)
# that account if THIS script created it on a previous run (tracked via the
# marker file below). Otherwise we'd silently overwrite the password of some
# pre-existing real account just because a student picked a colliding name
# in .env - refuse instead, so the failure is loud and obvious.
if id "$HONEYPOT_USER" >/dev/null 2>&1; then
    if [ ! -f "$MANAGED_USER_MARKER" ] || [ "$(cat "$MANAGED_USER_MARKER")" != "$HONEYPOT_USER" ]; then
        echo "[shelLM] ERROR: a user named '$HONEYPOT_USER' already exists and wasn't created by this script." >&2
        echo "[shelLM] Refusing to overwrite its password. Pick a different HONEYPOT_USER in .env." >&2
        exit 1
    fi
else
    useradd -m -s /bin/bash "$HONEYPOT_USER"
fi
echo "${HONEYPOT_USER}:${HONEYPOT_PASSWORD}" | chpasswd
echo "$HONEYPOT_USER" > "$MANAGED_USER_MARKER"

# shellm_app needs to be writable by the honeypot user (logs, command history)
chown -R "${HONEYPOT_USER}":"${HONEYPOT_USER}" "$APP_DIR/shellm_app"

# sshd_config's Match block must target whatever HONEYPOT_USER actually is, and
# listen on whatever PORT is configured - rewrite both here (idempotent: always
# replaces whatever is currently there) so changing either in .env doesn't
# silently leave the old values in effect.
sed -i "s/^Match User .*/Match User ${HONEYPOT_USER}/" "$SSHD_CONFIG"
sed -i "s/^Port .*/Port ${PORT}/" "$SSHD_CONFIG"

chmod +x "$APP_DIR/docker_config/run_shellm.sh"
mkdir -p /run/sshd

echo "[shelLM] Honeypot ready - sshd listening on port ${PORT} as user '${HONEYPOT_USER}'."
exec /usr/sbin/sshd -f "$SSHD_CONFIG" -D -e
