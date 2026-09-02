#!/bin/bash

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
    echo "Error: sshpass is not installed. Please install it and try again." >&2
    exit 1
fi

# Check if docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: docker is not installed. Please install it and try again." >&2
    exit 1
fi

project_started=false
cleanup_done=false
cleanup_failed=false

show_dashboard_logs () {
    echo ""
    echo "Last 20 lines from scl-dashboard:"
    docker logs --tail 20 scl-dashboard 2>&1 || \
        echo "WARNING - could not read scl-dashboard logs" >&2
}

cleanup () {
    if [ "$cleanup_done" = true ] || [ "$project_started" != true ]; then
        return
    fi
    cleanup_done=true

    echo ""
    echo "Stopping all challenges"
    local response
    response=$(curl -sS --max-time 120 -X POST http://127.0.0.1/api/challenges/stop/all 2>&1)
    if [ "$response" != "All stopped! 🎉" ]; then
        echo "WARNING - error stopping all challenges, got response: $response" >&2
        cleanup_failed=true
    else
        echo "All challenges stopped"
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

trap on_exit EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Fire up all the containers
echo ""
echo "Starting the project"
project_started=true
if ! docker compose up -d --build --force-recreate; then
    echo "Error starting the project" >&2
    show_dashboard_logs
    exit 3
fi
echo "Project started"

# Wait for the dashboard to initialize
sleep 2

LABUSER='root'
LABPASS='ByteThem123'
LABHOST='127.0.0.1'
LABPORT=2222

CHALLENGES_DIR="challenges"
CAMPAIGNS_DIR="campaigns"

echo ""
echo "Starting all challenges"
response=$(curl -s -X POST http://127.0.0.1/api/challenges/start/all)
if [ "$response" != "All started! 🎉" ]; then
    echo "Error starting all the challenges, got response: $response"
    show_dashboard_logs
    exit 3
fi
echo "All challenges started"

failed=()

solve () {
    local chal_dir=$1
    if [[ "$chal_dir" == *"template"* ]]; then
        # skip template
        return 0
    fi

    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
    echo "Testing $chal_dir:"

    local solve_script="$chal_dir/auto-solve.sh"
    local solve_deps="$chal_dir/auto-solve"
    if [ -f "$solve_script" ]; then
        # Copy auto-solve script into /tmp dir in hackerlab container
        # We use ssh instead of docker exec to test also the SSH connection
        sshpass -p "$LABPASS" scp -O \
                -o LogLevel=error \
                -o UserKnownHostsFile=/dev/null \
                -o StrictHostKeyChecking=no \
                -P $LABPORT \
                $solve_script \
                $LABUSER@$LABHOST:/tmp/auto-solve.sh

        # also copy all potential dependencies of the solve script
        if [ -d "$solve_deps" ]; then
            sshpass -p "$LABPASS" scp -O \
                    -o LogLevel=error \
                    -o UserKnownHostsFile=/dev/null \
                    -o StrictHostKeyChecking=no \
                    -P $LABPORT \
                    -r \
                    $solve_deps \
                    $LABUSER@$LABHOST:/tmp/
        fi
        # Run the auto-solve script from within the hackerlab container
        sshpass -p "$LABPASS" ssh \
                -o LogLevel=error \
                -o UserKnownHostsFile=/dev/null \
                -o StrictHostKeyChecking=no \
                -p $LABPORT \
                $LABUSER@$LABHOST \
                'cd /tmp && bash auto-solve.sh'

        local retVal=$?
        if [ $retVal -ne 0 ]; then
          return 1
        fi

    else
        echo "WARNING - missing $solve_script script"
        return 0
    fi

    printf "\n\n\n"
}

for chal_dir in "$CHALLENGES_DIR"/*/; do
    if ! solve "$chal_dir"; then
        failed+=("$chal_dir")
    fi
done
for campaign_dir in "$CAMPAIGNS_DIR"/*/; do
    if [[ "$campaign_dir" == *"example"* ]]; then
        # skip example
        continue
    fi
    for chal_dir in "$campaign_dir"*/; do
        if [[ "$chal_dir" == *"pages"* ]]; then
          # skip static pages
          continue
        fi
        if ! solve "$chal_dir"; then
            failed+=("$chal_dir")
        fi
    done
done

cleanup
trap - EXIT

if [ "$cleanup_failed" = true ]; then
    exit 3
fi

echo ""
if (( ${#failed[@]} != 0 )); then
    echo "❌ TEST FAILED - some auto-solve.sh script(s) failed:"
    for f in "${failed[@]}"; do
      echo " - $f"
    done
    exit 2
else
    echo "✅ ALL TESTS PASSED"
fi
