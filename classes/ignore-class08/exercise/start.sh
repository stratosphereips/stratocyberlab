#!/bin/bash

set -e

echo "[*] Compiling..."
make

echo "[*] Starting ncat..."
mkdir -p running
touch running/you-made-it

chmod o+w /opt/running

# drop root privileges and start listener
su user -c "cd /opt/running && nc -v --keep-open -l -p 4444 -e ../main"
