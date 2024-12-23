#!/bin/bash
set -e

apt-get update
apt-get install -y sudo git python3-venv libssl-dev libffi-dev build-essential libpython3-dev python3-minimal authbind
adduser --disabled-password cowrie --gecos ""
cp ./autosolve-victim-user.sh /home/cowrie/autosolve-victim-user.sh

sudo -u cowrie bash /home/cowrie/autosolve-victim-user.sh
