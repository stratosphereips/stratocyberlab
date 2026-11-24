#!/bin/sh
set -eu

redis-server --bind 0.0.0.0 --protected-mode no --save '' --appendonly no --dir /tmp --aclfile /opt/users.acl &
server_pid=$!

attempt=0
until redis-cli -h 127.0.0.1 ping >/dev/null 2>&1; do
  attempt=$((attempt + 1))
  if [ "$attempt" -ge 30 ]; then
    exit 1
  fi
  sleep 1
done

redis-cli -h 127.0.0.1 -x SET dump:sealed-ledger < /opt/ledger.txt >/dev/null
redis-cli -u redis://courier:ion-lantern-72@127.0.0.1 SET vault:dispatch 'BSY{14RjLHjB70QIivWTMdfVKsTiCiHF2DJp}' >/dev/null

wait "$server_pid"
