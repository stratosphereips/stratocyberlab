#!/bin/bash
set -e

submit_flag() {
    local task_id=$1
    local flag=$2

    RES=$(curl -s 'http://172.20.0.3/api/challenges/submit' \
        -X POST \
        -H 'Content-Type: application/json' \
        --data-binary '{"challenge_id": "knock-knock", "task_id": "'"$task_id"'", "flag": "'"$flag"'"}')

    if [[ $RES != *"Congratulations"* ]]; then
        echo "Failed to submit flag for $task_id - $RES"
        exit 2
    fi
    echo "Flag submitted for $task_id"
}

# https://unix.stackexchange.com/a/413011 - avoid prompting the user during WS install
echo "wireshark-common wireshark-common/install-setuid boolean false" | debconf-set-selections
apt-get install -y tshark >/dev/null

# hardcoding ip because the other 'repository' will be online as well during testing
wget -q http://172.20.0.204/network.pcapng
other_ip=$(tshark -r network.pcapng | grep SSH | grep -Po '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+' | head -1)
submit_flag "whos-there" "$other_ip"

wget -q http://172.20.0.204/fs-inotify.log
timestamp=$(grep "file.txt" fs-inotify.log | head -1 | cut -c 1-19)
submit_flag "whens-there" "$timestamp"

rm network.pcapng
rm fs-inotify.log

echo "OK - tests passed"
