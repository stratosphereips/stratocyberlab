#!/bin/bash

FLAG=`curl -s "172.20.0.5:8000/index.html" | \
       grep -o 'BSY{simple-hello-world-flag}'`
if [[ "$FLAG" == "" ]]
then
    echo "Error - the test failed"
    exit 1
fi

MATCH=`cat ~/.flag.txt | \
       grep -o "BSY{6JmUwlxDMqAi7LGKyDifntSZuFCku7KaTbnYxkSvziYBLg4AwCjubDeBQHxE}"`
if [[ "$MATCH" == "" ]]
then
    echo "Error - flag is not present in the home directory of hackerlab"
    exit 3
fi

# submit a flag in the submission server
RES=`curl -s 'http://172.20.0.3/api/challenges/submit' \
    -X POST \
    -H 'Content-Type: application/json' \
    --data-binary '{"challenge_id": "hello-world", "task_id": "task2", "flag" : "BSY{6JmUwlxDMqAi7LGKyDifntSZuFCku7KaTbnYxkSvziYBLg4AwCjubDeBQHxE}"}'`

if [[ $RES != *"Congratulations"* ]]; then
  echo "Failed to submit the flag - $RES"
  exit 4
fi


# submit a flag in the submission server
RES=`curl -s 'http://172.20.0.3/api/challenges/submit' \
    -X POST \
    -H 'Content-Type: application/json' \
    --data-binary '{"challenge_id": "hello-world", "task_id": "task3", "flag" : "BSY{simple-hello-world-flag}"}'`
if [[ $RES != *"Congratulations"* ]]; then
  echo "Failed to submit the flag - $RES"
  exit 5
fi

echo "OK - tests passed"
