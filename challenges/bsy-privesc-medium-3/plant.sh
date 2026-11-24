#!/bin/bash
set -euo pipefail

useradd --create-home --shell /bin/bash rookie
printf '%s:%s\n' rookie 'orbit-arcade-74' | chpasswd

printf '%s\n' 'BSY{Wvenc47CptfKZAgtspPpNFLJuznQ2Glu}' > /root/flag
chown root:root /root/flag
chmod 0400 /root/flag
printf '%s\n' 'escproof-90bf3fa63125e29d904013224156cd80' > /root/.escalation-proof
chown root:root /root/.escalation-proof
chmod 0400 /root/.escalation-proof

# Clear inherited SUID bits, then plant the single exploitable binary and one harmless decoy.
find / -xdev -type f -perm /4000 -exec chmod u-s {} +
cp /usr/bin/true /usr/local/bin/archive-check
chown root:root /usr/local/bin/archive-check
chmod 4755 /usr/local/bin/archive-check
chown root:root /usr/bin/find
chmod 4755 /usr/bin/find
