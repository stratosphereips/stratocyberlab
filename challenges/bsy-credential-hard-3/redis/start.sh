#!/bin/sh
set -eu
redis-server --bind 0.0.0.0 --protected-mode no --requirepass "$REDIS_PASSWORD" &
redis_pid=$!
until redis-cli -a "$REDIS_PASSWORD" ping >/dev/null 2>&1; do
  sleep 1
done
redis-cli -a "$REDIS_PASSWORD" SET actuator:flag 'BSY{4R1RqP3dL5JjZlpFbO9xMP0a3yEP7R2i}' >/dev/null
wait "$redis_pid"
