#!/bin/bash

MATCH=`sshpass -p "i_am_administrator" ssh -q \
        -o UserKnownHostsFile=/dev/null \
        -o StrictHostKeyChecking=no \
        root@172.20.0.41 cat /var/spool/cron/crontabs/charlie | \
        grep -o OFL{9xCyoIOLhJgFkx6Bd62NNhLPyvaMp0PLnlZwSFq5BHccDkKCGLgT9uNnOwwW}`
if [[ "$MATCH" == "" ]]
then
    echo "Error - did not find the rot13 encoded flag in a charlie's crontab"
    exit 1
fi

# submit a flag in the submission server
RES=`curl -s 'http://172.20.0.3/api/challenges/submit' \
    -X POST \
    -H 'Content-Type: application/json' \
    --data-binary '{"challenge_id": "intrusion", "task_id": "task1", "flag" : "BSY{9kPlbVBYuWtSxk6Oq62AAuYClinZc0CYayMjFSd5OUppQxXPTYtG9hAaBjjJ}"}'`
if [[ $RES != *"Congratulations"* ]]; then
  echo "Failed to submit the flag - $RES"
  exit 2
fi

echo "OK - tests passed"

