#!/bin/bash

# try to get the payload with all required data
nc -lnvp 1337 > received.data 2> /dev/null

# search for the 1st flag
MATCH=`strings received.data | head -n1 | base64 -d 2> /dev/null | \
       grep -o "BSY{a!sk&fjlhý76S5F9OUILFNRQKJLRHIUFKHAS}"`
if [[ "$MATCH" == "" ]]
then
    echo "Error - did not find a 1st base64 encoded flag in the received data"
    exit 1
fi

# submit the 1st flag
RES=`curl -s 'http://172.20.0.3/api/challenges/submit' \
    -X POST \
    -H 'Content-Type: application/json' \
    --data-binary '{"challenge_id": "leet_messenger_id", "task_id": "task1", "flag" : "BSY{a!sk&fjlhý76S5F9OUILFNRQKJLRHIUFKHAS}"}'`

if [[ $RES != *"Congratulations"* ]]; then
  echo "Failed to submit the 1st flag - $RES"
  exit 2
fi


# if the machine is x86, run the binary with a correct input (2nd flag) to see if it outputs expected output.
# (first we have to extract the binary tho)
if [ "$(uname -m)" == "x86_64" ] || [ "$(uname -m)" == "i686" ]; then
    binwalk -e received.data --run-as=root > /dev/null
    chmod +x ./_received.data.extracted/binary
    MATCH=`./_received.data.extracted/binary iam-reverse-king | grep -o "You found it! You can submit the flag, good job :)"`
    if [[ "$MATCH" == "" ]]
    then
        echo "Error - inputting correct input to the binary did not print expected output"
        exit 3
    fi

    RES=`curl -s 'http://172.20.0.3/api/challenges/submit' \
        -X POST \
        -H 'Content-Type: application/json' \
        --data-binary '{"challenge_id": "leet_messenger_id", "task_id": "task2", "flag" : "iam-reverse-king"}'`
    if [[ $RES != *"Congratulations"* ]]; then
      echo "Failed to submit the 2st flag - $RES"
      exit 4
    fi

else
    echo "Skipping check of 2nd flag because this is probably not x86 machine. so I cannot run the ELF x86 binary"
fi


echo "OK - tests passed"
exit 0


