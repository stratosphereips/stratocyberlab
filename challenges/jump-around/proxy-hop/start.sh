#!/bin/bash

# start the socks5 proxy in background
danted -f /etc/danted.conf -D

/usr/sbin/sshd -D
