#!/bin/bash

ip route del default
ip route add default via 10.0.0.4

# the user will have to do this anyway, but leaving for reference
export http_proxy=http://locproxy:8080
export https_proxy=http://locproxy:8080

while :; do
  sleep 1
done
