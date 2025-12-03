#!/usr/bin/env bash
set -euo pipefail

# --- Configurable paths ---
REPO_DIR="/StratosphereLinuxIPS"
APT_DEPS_FILE="/data/slips-apt-dependencies-small.txt"
PY_DEPS_FILE="/data/slips-requirements-small.txt"

# --- Sanity checks ---
if [ ! -f "$APT_DEPS_FILE" ]; then
  echo "ERROR: APT dependencies file not found: $APT_DEPS_FILE" >&2
  exit 1
fi

if [ ! -f "$PY_DEPS_FILE" ]; then
  echo "ERROR: Python requirements file not found: $PY_DEPS_FILE" >&2
  exit 1
fi

# --- 1. Shallow clone Slips repo (if not already present) ---
if [ ! -d "$REPO_DIR/.git" ]; then
  echo "[*] Cloning StratosphereLinuxIPS into $REPO_DIR..."
  git clone --depth 1 https://github.com/stratosphereips/StratosphereLinuxIPS "$REPO_DIR"
else
  echo "[*] $REPO_DIR already exists, skipping clone."
fi

cd "$REPO_DIR"

# --- 2. Add Zeek APT repo & install Zeek ---
if [ ! -f /etc/apt/sources.list.d/security:zeek.list ]; then
  echo "[*] Adding Zeek APT repository..."
  echo 'deb https://download.opensuse.org/repositories/security:/zeek/xUbuntu_22.04/ /' \
    > /etc/apt/sources.list.d/security:zeek.list

  curl -fsSL \
    https://download.opensuse.org/repositories/security:zeek/xUbuntu_22.04/Release.key \
    | gpg --dearmor > /etc/apt/trusted.gpg.d/security_zeek.gpg
else
  echo "[*] Zeek APT repository already configured, skipping."
fi

echo "[*] Updating APT cache..."
export DEBIAN_FRONTEND=noninteractive
apt-get update

echo "[*] Installing Zeek..."
apt-get install -y zeek-8.0

# --- 3. Install Linux dependencies from your small list ---
echo "[*] Installing additional APT dependencies from $APT_DEPS_FILE..."
xargs -a "$APT_DEPS_FILE" apt-get install -y --no-install-recommends

# --- 4. Python venv + requirements ---
if [ ! -d "venv" ]; then
  echo "[*] Creating Python virtual environment..."
  python3 -m venv venv
else
  echo "[*] venv already exists, reusing."
fi

echo "[*] Activating venv and installing Python dependencies..."
# shellcheck disable=SC1091
source venv/bin/activate

python3 -m pip install --upgrade pip
python3 -m pip install -r "$PY_DEPS_FILE"

echo "[✔] Slips installation completed."

