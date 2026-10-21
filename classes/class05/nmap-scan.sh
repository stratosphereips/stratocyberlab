#!/bin/sh

while :; do
  nmap -v -p 80 -sV 172.20.0.2
  sleep 60
done
