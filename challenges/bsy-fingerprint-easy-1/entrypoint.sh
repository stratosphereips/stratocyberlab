#!/bin/sh
set -eu

python3 /challenge/decoys.py &
redis-server --bind 0.0.0.0 --port 2323 --protected-mode no &
redis_pid=$!

attempt=0
until redis-cli -p 2323 PING >/dev/null 2>&1; do
  attempt=$((attempt + 1))
  if [ "$attempt" -ge 30 ]; then
    echo "Redis did not become ready" >&2
    exit 1
  fi
  sleep 1
done

FLAG='BSY{uyi22lkadRO8pOrPVOMmE0MmCdqzHGjU}'
redis-cli -p 2323 SET archive:sector7 "$FLAG" >/dev/null
wait "$redis_pid"
