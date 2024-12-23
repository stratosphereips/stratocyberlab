#!/bin/bash
set -e

cd

# install cowrie - steps as per https://docs.cowrie.org/en/latest/INSTALL.html
git clone http://github.com/cowrie/cowrie
cd cowrie
python3 -m venv cowrie-env
source cowrie-env/bin/activate
python -m pip install --upgrade -r requirements.txt

# create a custom userdb with only one user
cat >etc/userdb.txt <<EOF
debian:x:345gs5662d34
EOF

# change hostname
cat >etc/cowrie.cfg <<EOF
[honeypot]
hostname = notapot
EOF

# TODO: to change port: [ssh]\nlisten_endpoints = tcp:22:interface=0.0.0.0

# make `ping` to the weird ip fail
line=$(grep -n 'def valid_ip(' src/cowrie/commands/ping.py | cut -f1 -d ':')
line=$((line + 1))
sed -i "$line"'i \ \ \ \ \ \ \ \ return False' src/cowrie/commands/ping.py

# make `ls`` find the newly created file
line=$(grep -n 'def do_ls_normal(' src/cowrie/commands/ls.py | cut -f1 -d ':')
line=$((line + 1))
sed -i "$line"'i \ \ \ \ \ \ \ \ return self.write("test.txt\\n")' src/cowrie/commands/ls.py

# 'implement' the `find` command exactly how we want it - to return a shell
cat >src/cowrie/commands/find.py <<EOF
from cowrie.shell.command import HoneyPotCommand

commands = {}

class Command_find(HoneyPotCommand):
	def call(self):
		self.write("/bin/bash\n")


commands['find'] = Command_find
EOF

# and register it
line=$(grep -n '__all__ =' src/cowrie/commands/__init__.py | cut -f1 -d ':')
line=$((line + 1))
sed -i "$line"'i \ \ \ \ "find",' src/cowrie/commands/__init__.py

bin/cowrie start

# wait until the flag file is created
set +e
while :; do
	flag=$(grep 'M1r0' -hr var/lib/cowrie/downloads/)
	# shellcheck disable=SC2181
	if [ $? -eq 0 ]; then
		break
	fi
	sleep 1
done
set -e

echo "Flag is $flag"

echo "$flag" > ~/flag
