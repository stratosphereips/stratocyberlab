#!/bin/bash

#                           _       _
#                          | |     | |
#  _ __ _____   _____  __ _| |  ___| |_ ___  __ _  __ _ _ __   ___
# | '__/ _ \ \ / / _ \/ _` | | / __| __/ _ \/ _` |/ _` | '_ \ / _ \
# | | |  __/\ V /  __/ (_| | | \__ \ ||  __/ (_| | (_| | | | | (_) |
# |_|  \___| \_/ \___|\__,_|_| |___/\__\___|\__, |\__,_|_| |_|\___/
#                                            __/ |
#                                           |___/

# TODO: pip install Stegano
# TODO: install steghide

stegano-lsb reveal -i level-2.png -o l1re.jpg
steghide extract -sf l1re.jpg -xf l0re.txt -p ""

#                                           _
#                                          (_)
#  _ __ _____   _____ _ __ ___  ___  __   ___  __ _  ___ _ __   ___ _ __ ___
# | '__/ _ \ \ / / _ \ '__/ __|/ _ \ \ \ / / |/ _` |/ _ \ '_ \ / _ \ '__/ _ \
# | | |  __/\ V /  __/ |  \__ \  __/  \ V /| | (_| |  __/ | | |  __/ | |  __/
# |_|  \___| \_/ \___|_|  |___/\___|   \_/ |_|\__, |\___|_| |_|\___|_|  \___|
#                                              __/ |
#                                             |___/

to_chars() {
	read inp
	echo "$inp" | od -An -t u1 | xargs
}

len=$(cat l0re.txt | wc -c | xargs)
read -r -a ct <<< $(cat l0re.txt | to_chars)
read -r -a key <<< $(echo "key" | to_chars)

to_text() {
	echo $(awk 'BEGIN{printf "%c",'$1'}')
}

out=""
i=0
for c in "${ct[@]}"; do
	if (( c < 97 )) || (( c > 122 )); then
		# echo $c
		l=$(to_text $c)
		out="$out$l"
		continue
	fi
	k=$(($i % 3))
	k=${key[$k]}
	o=$(($c - $k))
	o=$(($o % 26))
	if (( o < 0 )); then
		o=$(($o + 26))
	fi
	o=$(($o + 97))

	# echo "$c ct"
	# echo "$k key"
	# echo "$o ot"
	l=$(to_text $o)
	out="$out$l"
	i=$(($i + 1))
done

echo $out
