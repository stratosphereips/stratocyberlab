#!/bin/sh
set -eu
mkdir -p /run/sshd
ssh-keygen -A
/usr/sbin/sshd -t
exec /usr/sbin/sshd -D -e
