#!/bin/sh

export HOST=bearific-victim
export PORT=2222

while ! python3 bearific-ssh-attacker.py; do
  echo "Restarting in 5 seconds..."
  sleep 5
done

echo "Done, quitting for now"
