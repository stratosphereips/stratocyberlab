#!/bin/sh
set -eu

cat > /tmp/redis.conf <<EOF
bind 0.0.0.0
protected-mode yes
port 6379
save ""
appendonly no
user default off
user panel_ops on >${REDIS_PASSWORD} ~airlock:* +get +set +ping
EOF

redis-server /tmp/redis.conf &
redis_pid=$!
trap 'kill "$redis_pid" 2>/dev/null || true' EXIT INT TERM

until redis-cli --user panel_ops --pass "$REDIS_PASSWORD" ping >/dev/null 2>&1; do
    kill -0 "$redis_pid"
    sleep 0.2
done

flag=$(cat /srv/flag.txt)
redis-cli --user panel_ops --pass "$REDIS_PASSWORD" SET airlock:manifest "$flag" >/dev/null
wait "$redis_pid"
