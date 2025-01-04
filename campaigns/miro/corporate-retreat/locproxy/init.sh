#!/bin/bash

echo "Configuring routing..."

ip route del default
ip route add default via 10.0.0.4

echo "Starting proxy"

mitmdump --set confdir=/app -w /var/proxy/web-proxy.log
