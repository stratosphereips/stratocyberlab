#!/bin/bash

service vsftpd start

python3 -m http.server 8080 --directory /var/www &

tail -f /dev/null