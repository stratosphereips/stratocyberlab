#!/bin/bash

FLAG=`curl -s "172.20.0.3:8000/index.html" | \
       grep -o 'bsy{simple-hello-world-flag}'`
if [[ "$FLAG" == "" ]]
then
    echo "The test failed"
    exit 1
fi

echo "OK - test passed"


