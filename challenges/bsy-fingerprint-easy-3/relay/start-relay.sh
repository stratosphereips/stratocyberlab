#!/bin/sh
set -eu
flag='BSY{hqSjb9Pu9Kb4W1TPyLRTRolq7of9XyHu}'
mosquitto -c /etc/mosquitto/mosquitto.conf &
broker_pid=$!
trap 'kill "$broker_pid" 2>/dev/null || true' EXIT INT TERM
ready=0
for attempt in $(seq 1 30); do
  if mosquitto_pub -h 127.0.0.1 -p 18883 -t rover/telemetry/archive -m "$flag" -r 2>/dev/null; then
    ready=1
    break
  fi
  sleep 1
done
if [ "$ready" -ne 1 ]; then
  exit 1
fi
wait "$broker_pid"
