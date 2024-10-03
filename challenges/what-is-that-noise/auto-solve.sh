#!/bin/bash

# Capture ICMP packets for 10 seconds and save them to a temporary file
echo "sniffing packets for 10 seconds, wait with me!"
tcpdump -i eth0 icmp -w /tmp/icmp_capture.pcap -G 10 -W 1 > /dev/null 2>&1

# Convert the capture file to human-readable format
tcpdump -A -r /tmp/icmp_capture.pcap > /tmp/icmp_capture.txt

MATCH=`grep -o "OFL{l5egjrfqbvehsjrvbeqfghsbvrheqsbvqfhjr45423344255342343yyyyjj}" /tmp/icmp_capture.txt`
if [[ "$MATCH" == "" ]]
then
    echo "Error - did not find the encrypted flag in ICMP packets"
    exit 1
fi

# Clean up
rm /tmp/icmp_capture.pcap /tmp/icmp_capture.txt

# submit a flag in the submission server
RES=`curl -s 'http://172.20.0.3/api/challenges/submit' \
    -X POST \
    -H 'Content-Type: application/json' \
    --data-binary '{"challenge_id": "what-is-that-noise-id", "task_id": "task1", "flag" : "BSY{y5rtwesdoirufweiordstufoieurdfoidsuwe45423344255342343llllww}"}'`

if [[ $RES != *"Congratulations"* ]]; then
  echo "Failed to submit the flag - $RES"
  exit 2
fi

echo "OK - tests passed"
exit 0


