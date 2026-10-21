#!/bin/bash
# ForceCommand target - this is what the honeypot user actually gets dropped
# into on login, instead of a real shell.
APP_DIR="/opt/shellm"

# personality_prompt.yaml at the top level is the single file you're meant to
# edit. The app itself looks for it inside LLM_Plugins/personalities/, so
# re-sync that copy from the top-level file on every connection - this way
# an edit always takes effect on your very next connection, with no separate
# "don't forget to copy it over" step to get out of sync.
cp "$APP_DIR/personality_prompt.yaml" \
   "$APP_DIR/shellm_app/LLM_Plugins/personalities/personality_prompt.yaml"

cd "$APP_DIR/shellm_app"

if [ -f "$APP_DIR/.env" ]; then
    set -a
    source "$APP_DIR/.env"
    set +a
fi

PROVIDER="${PROVIDER:-einfra}"
MODEL="${MODEL:-gpt-oss-120b}"

exec python3 LinuxSSHbot.py --provider "$PROVIDER" --model "$MODEL" --personality personality_prompt --trace
