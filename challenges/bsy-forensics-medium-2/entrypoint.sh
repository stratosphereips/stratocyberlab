#!/bin/sh
set -eu
exec /usr/sbin/sshd -D -e
