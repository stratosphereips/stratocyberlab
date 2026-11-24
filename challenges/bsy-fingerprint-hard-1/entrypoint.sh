#!/bin/sh
set -eu

FLAG='BSY{45iH0GQVB5QnzOMQMnhgRNchR0bVMwuu}'
redis-server --port 45117 --bind 0.0.0.0 --protected-mode no --save '' --appendonly no &
redis_pid=$!

ready=0
for attempt in $(seq 1 30); do
    if redis-cli -h 127.0.0.1 -p 45117 PING 2>/dev/null | grep -q PONG; then
        ready=1
        break
    fi
    sleep 1
done
if [ "$ready" -ne 1 ]; then
    echo 'BBS record store did not start' >&2
    exit 1
fi
redis-cli -h 127.0.0.1 -p 45117 SET 'bbs:night-shift' "$FLAG" >/dev/null
unset FLAG

python3 /opt/bbs/decoys.py &
wait "$redis_pid"
