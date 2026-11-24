#!/bin/sh
set -eu

redis-server --bind 0.0.0.0 --protected-mode no --port 6379 &
redis_pid=$!
trap 'kill "$redis_pid" 2>/dev/null || true' EXIT TERM INT

until redis-cli ping >/dev/null 2>&1; do sleep 0.2; done

redis-cli SET brief:entries 'ops-lyra / Vanta!73 | ops-nyx / Cobalt#19 | svc-orion / IonDrive_44 | ops-vega / Quartz$82' >/dev/null
redis-cli SET brief:archive 'Night-shift backup manifest: active vault principal = svc-orion. Other listed identities are absent from the authentication snapshot.' >/dev/null
redis-cli SET trap:ops-lyra 'SECURITY NOTICE: this access attempt has been logged for review.' >/dev/null
redis-cli SET trap:ops-nyx 'SECURITY NOTICE: this access attempt has been logged for review.' >/dev/null
redis-cli SET trap:ops-vega 'SECURITY NOTICE: this access attempt has been logged for review.' >/dev/null
redis-cli SET vault:record 'BSY{5ag46W8JrSjoUmFqMXMbsjoTQoeDGKUf}' >/dev/null

redis-cli ACL SETUSER default on nopass '~brief:*' '+get' '+ping' >/dev/null
redis-cli ACL SETUSER health on '>healthcheck-only' '~*' '+ping' >/dev/null
redis-cli ACL SETUSER ops-lyra on '>Vanta!73' '~trap:ops-lyra' '+get' '+ping' >/dev/null
redis-cli ACL SETUSER ops-nyx on '>Cobalt#19' '~trap:ops-nyx' '+get' '+ping' >/dev/null
redis-cli ACL SETUSER svc-orion on '>IonDrive_44' '~vault:*' '+get' '+ping' >/dev/null
redis-cli ACL SETUSER ops-vega on '>Quartz$82' '~trap:ops-vega' '+get' '+ping' >/dev/null

wait "$redis_pid"
