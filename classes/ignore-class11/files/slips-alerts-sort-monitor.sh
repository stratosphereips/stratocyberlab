#!/bin/bash

# Use first argument if provided, otherwise default to alerts.log
ALERTS_LOG="${1:-alerts.log}"

watch -d "/data/slips-alerts-sort.sh $ALERTS_LOG"

