#!/bin/bash
set -e

# copy the script setting up the honeypot to the victim
sshpass -p "alpine" scp -o StrictHostKeyChecking=no auto-solve/autosolve-victim* root@bearific-victim:~

# run it, it will wait until the attacker places the flag
sshpass -p "alpine" ssh root@bearific-victim bash ~/autosolve-victim-root.sh

# read the flag
flag=$(sshpass -p "alpine" ssh root@bearific-victim cat /home/cowrie/flag)

# submit the flag
RES=$(curl -s 'http://172.20.0.3/api/challenges/submit' \
    -X POST \
    -H 'Content-Type: application/json' \
    --data-binary '{"challenge_id": "bearific", "task_id": "left-behind", "flag": "'"$flag"'"}')
if [[ $RES != *"Congratulations"* ]]; then
  echo "Failed to submit the flag - $RES"
  exit 2
fi


echo "OK - tests passed"
