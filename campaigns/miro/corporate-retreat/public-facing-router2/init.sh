#!/bin/bash

echo "Starting ulogd"
ulogd -d

echo "Configuring iptables..."

# NATting
iptables -t nat -A POSTROUTING -j MASQUERADE --random

# debug only
#iptables -A FORWARD -j NFLOG

# prevent 172.20.0.250 (bread forum) from accessing the company network
iptables -I FORWARD -s 172.20.0.250 -p tcp --sport http -j DROP

# allow return communication
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

# allow outbound http(s) traffic only when proxied
iptables -A FORWARD -s 10.0.0.5/32 -p tcp -m multiport --dports 80,443 -j ACCEPT

# allow outbound SSH, but log it first
iptables -A FORWARD -p tcp --dport 22 -j NFLOG
iptables -A FORWARD -p tcp --dport 22 -j ACCEPT

# allow all ICMP
iptables -A FORWARD -p icmp -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT

# allow DNS
iptables -A FORWARD -p udp --dport 53 -j ACCEPT

# allow all incoming packets from inside the company
iptables -A INPUT -s 10.0.0.0/16 -j ACCEPT

# drop all else
iptables -A FORWARD -j DROP
iptables -A INPUT -j DROP

# export to where webmin can see
iptables-save >/etc/iptables.up.rules

/etc/webmin/start
echo "Started!"

sleep infinity
