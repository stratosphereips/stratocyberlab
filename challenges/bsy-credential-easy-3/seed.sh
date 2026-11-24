#!/bin/sh
set -eu
redis-server --requirepass scoreboard &
server_pid=$!
trap 'kill "$server_pid" 2>/dev/null || true' EXIT
until redis-cli -a scoreboard ping >/dev/null 2>&1; do
  sleep 0.2
done
redis-cli -a scoreboard SET arena:final "BSY{Pss8dQOlnzdMD2oBs0TalOmqgBBl5Aok}" >/dev/null
wait "$server_pid"
