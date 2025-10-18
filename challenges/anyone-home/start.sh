#!/bin/bash

set -e

/usr/sbin/sshd

python3 attacker.py