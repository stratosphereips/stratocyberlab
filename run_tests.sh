#!/bin/bash

DASHBOARD_URL='http://127.0.0.1'
LABUSER='root'
LABPASS='ByteThem123'
LABHOST='127.0.0.1'
LABPORT=2222

CHALLENGES_DIR='challenges'
CAMPAIGNS_DIR='campaigns'

for command in docker curl sshpass; do
    if ! command -v "$command" &> /dev/null; then
        echo "Error: $command is not installed. Please install it and try again." >&2
        exit 1
    fi
done

project_started=false
cleanup_done=false
cleanup_failed=false
active_challenge_id=''
active_challenge_dir=''
failed=()
checked=0
tested=0
startup_only=0

show_dashboard_logs () {
    echo ""
    echo "Last 20 lines from scl-dashboard:"
    docker logs --tail 20 scl-dashboard 2>&1 || \
        echo "WARNING - could not read scl-dashboard logs" >&2
}

dashboard_action () {
    local action=$1
    local challenge_id=$2

    curl -sS -X POST \
        --data-urlencode "challenge_id=$challenge_id" \
        "$DASHBOARD_URL/api/challenges/$action"
}

stop_challenge () {
    local challenge_id=$1
    local challenge_dir=$2
    local response

    echo "Stopping $challenge_dir"
    response=$(dashboard_action stop "$challenge_id" 2>&1)
    if [ "$response" != "Challenge stopped" ]; then
        echo "ERROR - could not stop $challenge_dir, got response: $response" >&2
        show_dashboard_logs
        return 1
    fi

    active_challenge_id=''
    active_challenge_dir=''
    echo "Stopped $challenge_dir"
}

cleanup () {
    if [ "$cleanup_done" = true ] || [ "$project_started" != true ]; then
        return
    fi
    cleanup_done=true

    if [ -n "$active_challenge_id" ]; then
        echo ""
        echo "Cleaning up the active challenge"
        if ! stop_challenge "$active_challenge_id" "$active_challenge_dir"; then
            cleanup_failed=true
        fi
    fi

    echo ""
    echo "Stopping the project"
    if ! docker compose down; then
        echo "WARNING - error stopping the project" >&2
        cleanup_failed=true
    else
        echo "Project stopped"
    fi
}

on_exit () {
    local status=$?
    trap - EXIT
    cleanup
    if [ "$status" -eq 0 ] && [ "$cleanup_failed" = true ]; then
        status=3
    fi
    exit "$status"
}

wait_for_dashboard () {
    local attempt

    for attempt in {1..60}; do
        if curl -fsS "$DASHBOARD_URL/live" > /dev/null; then
            return 0
        fi
        sleep 1
    done

    return 1
}

challenge_id_from_metadata () {
    local challenge_dir=${1%/}
    local metadata_path="/$challenge_dir/meta.json"

    docker exec scl-dashboard python -c \
        'import json, sys; print(json.load(open(sys.argv[1], encoding="utf-8"))["id"])' \
        "$metadata_path"
}

run_auto_solver () {
    local challenge_dir=$1
    local solve_script="$challenge_dir/auto-solve.sh"
    local solve_deps="$challenge_dir/auto-solve"
    local ssh_options=(
        -o LogLevel=error
        -o UserKnownHostsFile=/dev/null
        -o StrictHostKeyChecking=no
    )

    if [ ! -f "$solve_script" ]; then
        echo "No auto-solve.sh; startup check passed"
        ((startup_only += 1))
        return 0
    fi

    ((tested += 1))
    echo "Running $solve_script"

    if ! sshpass -p "$LABPASS" ssh \
        "${ssh_options[@]}" -p "$LABPORT" \
        "$LABUSER@$LABHOST" \
        'rm -rf /tmp/auto-solve.sh /tmp/auto-solve'; then
        return 1
    fi

    if ! sshpass -p "$LABPASS" scp -O \
        "${ssh_options[@]}" -P "$LABPORT" \
        "$solve_script" \
        "$LABUSER@$LABHOST:/tmp/auto-solve.sh"; then
        return 1
    fi

    if [ -d "$solve_deps" ]; then
        if ! sshpass -p "$LABPASS" scp -O -r \
            "${ssh_options[@]}" -P "$LABPORT" \
            "$solve_deps" \
            "$LABUSER@$LABHOST:/tmp/"; then
            return 1
        fi
    fi

    sshpass -p "$LABPASS" ssh \
        "${ssh_options[@]}" -p "$LABPORT" \
        "$LABUSER@$LABHOST" \
        'cd /tmp && bash auto-solve.sh'
}

check_challenge () {
    local challenge_dir=${1%/}
    local challenge_id
    local response

    printf '%*s\n' 80 '' | tr ' ' '-'
    echo "Checking $challenge_dir"

    if ! challenge_id=$(challenge_id_from_metadata "$challenge_dir"); then
        echo "ERROR - could not read the challenge ID from $challenge_dir/meta.json" >&2
        failed+=("$challenge_dir (metadata)")
        return 0
    fi

    ((checked += 1))
    active_challenge_id=$challenge_id
    active_challenge_dir=$challenge_dir

    echo "Starting $challenge_dir"
    response=$(dashboard_action start "$challenge_id" 2>&1)
    if [ "$response" != "Challenge started! 🎉" ]; then
        echo "ERROR - could not start $challenge_dir, got response: $response" >&2
        show_dashboard_logs
        failed+=("$challenge_dir (start)")

        if ! stop_challenge "$challenge_id" "$challenge_dir"; then
            return 1
        fi
        return 0
    fi

    if ! run_auto_solver "$challenge_dir"; then
        echo "ERROR - test failed for $challenge_dir" >&2
        failed+=("$challenge_dir (test)")
    fi

    if ! stop_challenge "$challenge_id" "$challenge_dir"; then
        failed+=("$challenge_dir (stop)")
        return 1
    fi

    echo "Finished $challenge_dir"
    echo ""
}

trap on_exit EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

echo ""
echo "Starting the project"
project_started=true
if ! docker compose up -d --build --force-recreate; then
    echo "Error starting the project" >&2
    show_dashboard_logs
    exit 3
fi

if ! wait_for_dashboard; then
    echo "Error: dashboard did not become ready within 60 seconds" >&2
    show_dashboard_logs
    exit 3
fi
echo "Project started"

for challenge_dir in "$CHALLENGES_DIR"/*/; do
    if [ "${challenge_dir%/}" = "$CHALLENGES_DIR/template" ]; then
        continue
    fi

    if ! check_challenge "$challenge_dir"; then
        exit 3
    fi
done

for campaign_dir in "$CAMPAIGNS_DIR"/*/; do
    if [ "${campaign_dir%/}" = "$CAMPAIGNS_DIR/example" ]; then
        continue
    fi

    for challenge_dir in "$campaign_dir"*/; do
        if [ ! -f "$challenge_dir/meta.json" ] || [ ! -f "$challenge_dir/docker-compose.yml" ]; then
            continue
        fi

        if ! check_challenge "$challenge_dir"; then
            exit 3
        fi
    done
done

cleanup
trap - EXIT

if [ "$cleanup_failed" = true ]; then
    exit 3
fi

echo ""
echo "Checked $checked challenges ($tested tested, $startup_only startup-only)"
if (( ${#failed[@]} != 0 )); then
    echo "❌ TEST FAILED:"
    for failure in "${failed[@]}"; do
        echo " - $failure"
    done
    exit 2
fi

echo "✅ ALL TESTS PASSED"
