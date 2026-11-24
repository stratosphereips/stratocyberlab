#!/bin/bash
set -eu

printf '%s\n' 'BSY{GgINe4h7W2f1KD6GvZSlt056TLumNfZD}' > /root/flag
chown root:root /root/flag
chmod 0400 /root/flag

printf '%s\n' 'escproof-c9750ea03e4a45e029fcb765e03c3e23' > /root/.escalation-proof
chown root:root /root/.escalation-proof
chmod 0400 /root/.escalation-proof

# Decoy: a copied system utility with no input-driven behavior.
cp /bin/true /usr/local/bin/ledger-check
chown root:root /usr/local/bin/ledger-check
chmod 4755 /usr/local/bin/ledger-check

# Intended escalation primitive: a standard file-search utility with SUID.
chown root:root /usr/bin/find
chmod 4755 /usr/bin/find
