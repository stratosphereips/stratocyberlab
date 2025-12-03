#!/bin/bash

# If an argument is provided, use it.
# Otherwise default to ./alerts.log
ALERTS_LOG="${1:-alerts.log}"

cat "$ALERTS_LOG" \
  | awk -F 'Detected' '{print $2}' \
  | grep "threat level: high" \
  | sort \
  | uniq -c \
  | sort -rn
