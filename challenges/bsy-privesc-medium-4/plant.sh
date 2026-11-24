#!/bin/bash
set -eu

# Remove distro set-id bits so the planted utilities are the only custom footholds.
find / -xdev -type f -perm /6000 -exec chmod a-s {} + 2>/dev/null || true
chmod 4755 /usr/bin/sudo

cat > /root/flag <<'EOF'
BSY{iJfRy37WPxQulo9xheZRi4FkvRytQmSl}
EOF
chown root:root /root/flag
chmod 0400 /root/flag

cat > /root/.escalation-proof <<'EOF'
escproof-d4eee8d96f1329cb2cc47a0fe78025f7
EOF
chown root:root /root/.escalation-proof
chmod 0400 /root/.escalation-proof

cat > /tmp/vendor-maint.c <<'EOF'
#include <unistd.h>

int main(void) {
    char *const args[] = {"bash", "-p", "/home/tech/rotation.sh", NULL};
    execv("/bin/bash", args);
    return 1;
}
EOF

gcc -O2 -o /usr/local/bin/vendor-maint /tmp/vendor-maint.c
chown root:root /usr/local/bin/vendor-maint
chmod 4755 /usr/local/bin/vendor-maint

cat > /tmp/telemetry-peek.c <<'EOF'
#include <stdio.h>

int main(void) {
    puts("Maintenance telemetry: coolant loop nominal; no action required.");
    return 0;
}
EOF

gcc -O2 -o /usr/local/bin/telemetry-peek /tmp/telemetry-peek.c
chown root:root /usr/local/bin/telemetry-peek
chmod 4755 /usr/local/bin/telemetry-peek

cat > /home/tech/rotation.sh <<'EOF'
#!/bin/bash
printf '%s\n' 'Routine maintenance cycle complete.'
EOF
chown tech:tech /home/tech/rotation.sh
chmod 0700 /home/tech/rotation.sh

rm -f /tmp/vendor-maint.c /tmp/telemetry-peek.c
