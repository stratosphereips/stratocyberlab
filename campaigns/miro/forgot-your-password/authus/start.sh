#!/bin/bash

ip route del default
ip route add default via 172.21.0.2

sudo -u daemon java -jar ./*.jar
