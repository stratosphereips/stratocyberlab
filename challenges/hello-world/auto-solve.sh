#!/bin/bash

FLAG=`curl -s "172.20.0.5:8000/index.html" | \
       grep -o 'bsy{simple-hello-world-flag}'`
if [[ "$FLAG" == "" ]]
then
    echo "Error - the test failed"
    exit 1
fi

# submit a flag in the submission server
RES=`curl -s 'http://172.20.0.3/api/challenges/submit' \
    -X POST \
    -H 'Content-Type: application/json' \
    --data-binary '{"challenge_id": "hello-world", "task_id": "task2", "flag" : "bsy{simple-hello-world-flag}"}'`
if [[ $RES != *"Congratulations"* ]]; then
  echo "Failed to submit the flag - $RES"
  exit 5
fi

echo "OK - tests passed"
