#!/bin/bash

echo "Configuring iptables..."

# NATting
iptables -t nat -A POSTROUTING -j MASQUERADE --random

# debug only
#iptables -A FORWARD -j NFLOG

# allow returns - related connections + http(s) responses
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp -m multiport --sports 80,443 -j ACCEPT

# allow outbound http(s) traffic only when proxied
iptables -A FORWARD -s 10.0.0.5/32 -p tcp -m multiport --dports 80,443 -j ACCEPT

# allow DNS
iptables -A FORWARD -p udp -m udp --dport 53 -j ACCEPT
iptables -A FORWARD -p udp -m udp --sport 53 -j ACCEPT

# TODO allow inbound traffic?

# drop all else
iptables -A FORWARD -j DROP

echo "Started!"

while :; do
  sleep 1
done
