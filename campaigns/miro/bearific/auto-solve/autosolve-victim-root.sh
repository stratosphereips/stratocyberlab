#!/bin/bash
set -e

cp ./autosolve-victim-user.sh /home/cowrie/autosolve-victim-user.sh

sudo -u cowrie bash /home/cowrie/autosolve-victim-user.sh
