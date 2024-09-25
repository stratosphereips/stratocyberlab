#!/bin/bash

# Write a bash script that tests if a challenge is working.
# This script will be run from within a hackerlab container.
# Return non-zero exit code upon failure

# Test also submission of the flag in the submission server. You can use
# the following code snippet. Use flag, task and challenge IDs from your meta.json file
# 
# RES=`curl -s 'http://172.20.0.3/submit' \
#     -X POST \
#     -H 'Content-Type: application/json' \
#     --data-binary '{"challenge_id": "fill_id", "task_id": "fill_id", "flag" : "BSY{...}"}'`
# 
# if [[ $RES != *"Congratulations"* ]]; then
#   echo "Failed to submit the flag - $RES"
#   exit 5
# fi


echo "OK - tests passed"
exit 0


