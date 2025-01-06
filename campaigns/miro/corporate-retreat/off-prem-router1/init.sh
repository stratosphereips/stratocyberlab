#!/bin/bash

echo "Routing default through outbound router"
ip route del default
ip route add default via 10.0.0.4

echo "Configuring iptables"
# allow access to the admin interface always
iptables-legacy -A INPUT -p tcp --dport 10000 -j ACCEPT

# allow http(s)
iptables-legacy -A FORWARD -p tcp -m multiport --dports 80,443 -j ACCEPT
iptables-legacy -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

# and any forward attempts
iptables-legacy -A FORWARD -j DROP

# export to where webmin can see
iptables-legacy-save >/etc/iptables.up.rules

/etc/webmin/start
echo "Started!"

sleep infinity
