#!/bin/bash

echo "Configuring routing..."

ip route del default
ip route add default via 10.0.0.4

echo "Starting SSHd"
/usr/sbin/sshd

echo "Starting proxy"

mitmdump --set confdir=/app -w "/var/log/proxy/web-proxy-$(date --iso-8601).log"
