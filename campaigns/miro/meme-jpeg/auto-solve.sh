#!/bin/bash

#                           _       _
#                          | |     | |
#  _ __ _____   _____  __ _| |  ___| |_ ___  __ _  __ _ _ __   ___
# | '__/ _ \ \ / / _ \/ _` | | / __| __/ _ \/ _` |/ _` | '_ \ / _ \
# | | |  __/\ V /  __/ (_| | | \__ \ ||  __/ (_| | (_| | | | | (_) |
# |_|  \___| \_/ \___|\__,_|_| |___/\__\___|\__, |\__,_|_| |_|\___/
#                                            __/ |
#                                           |___/

echo "⬇️ Installing dependencies"
pip install --break-system-packages Stegano >/dev/null
apt-get install -y steghide >/dev/null

echo "⛏️ Breaking stegano"
wget -q http://172.20.0.205/attachments/c8edf7b6621df4bc6728f8642967530cec7ffcbcc0669353efd7c5f5211621ae.png
stegano-lsb reveal -i c8edf7b6621df4bc6728f8642967530cec7ffcbcc0669353efd7c5f5211621ae.png -o l1re.jpg
steghide extract -sf l1re.jpg -xf l0re.txt -p ""

#                                           _
#                                          (_)
#  _ __ _____   _____ _ __ ___  ___  __   ___  __ _  ___ _ __   ___ _ __ ___
# | '__/ _ \ \ / / _ \ '__/ __|/ _ \ \ \ / / |/ _` |/ _ \ '_ \ / _ \ '__/ _ \
# | | |  __/\ V /  __/ |  \__ \  __/  \ V /| | (_| |  __/ | | |  __/ | |  __/
# |_|  \___| \_/ \___|_|  |___/\___|   \_/ |_|\__, |\___|_| |_|\___|_|  \___|
#                                              __/ |
#                                             |___/

echo "⛏️ Breaking Vigenere"
to_chars() {
	read -r inp
	echo "$inp" | od -An -t u1 | xargs
}

read -r -a ct <<< "$(to_chars < l0re.txt)"
read -r -a key <<< "$(echo "key" | to_chars)"

to_text() {
	awk 'BEGIN{printf "%c",'$1'}'
}

out=""
i=0
for c in "${ct[@]}"; do
	if (( c < 97 )) || (( c > 122 )); then
		l=$(to_text "$c")
		out="$out$l"
		continue
	fi
	k=$((i % 3))
	k=${key[$k]}
	o=$((c - k))
	o=$((o % 26))
	if (( o < 0 )); then
		o=$((o + 26))
	fi
	o=$((o + 97))

	l=$(to_text $o)
	out="$out$l"
	i=$((i + 1))
done

echo "⬆️ POSTing flag $out"
RES=$(curl -s 'http://172.20.0.3/api/challenges/submit' \
   -X POST \
   -H 'Content-Type: application/json' \
   --data-binary "{\"challenge_id\": \"meme-jpeg\", \"task_id\": \"destination\", \"flag\" : \"$out\"}")

if [[ $RES != *"Congratulations"* ]]; then
 echo "Failed to submit the flag - $RES"
 exit 5
fi

echo "OK - tests passed"
