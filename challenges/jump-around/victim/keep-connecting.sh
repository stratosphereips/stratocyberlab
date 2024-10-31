#!/bin/bash

/usr/sbin/sshd

while true; do
    curl -X POST -x socks5h://172.20.0.47:1080 http://172.20.0.45/login -H "Authorization: Basic YWRtaW46c3VwZXItc2VjcmV0LXBhc3N3b3JkLWNhbm5vdC1iZS1ndWVzc2VkCg=="
    sleep 5
done
