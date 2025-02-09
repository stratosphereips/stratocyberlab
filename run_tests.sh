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

# Fire up all the containers
echo ""
echo "Starting the project"
docker compose up -d --build --force-recreate
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
    exit 3
fi
echo "All challenges started"

failed=false
solve () {
    local chal_dir=$1
    if [[ "$chal_dir" == *"template"* ]]; then
        # skip template
        return 0
    fi

    echo ""
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
            failed=true
        fi

    else
        echo "WARNING - missing $solve_script script"
    fi
}

for chal_dir in "$CHALLENGES_DIR"/*/; do
    if ! solve "$chal_dir"; then
        failed=true
    fi
done
for campaign_dir in "$CAMPAIGNS_DIR"/*/; do
    if [[ "$campaign_dir" == *"example"* ]]; then
        # skip example
        continue
    fi
    for chal_dir in "$campaign_dir"*/; do
        if ! solve "$chal_dir"; then
            failed=true
        fi
    done
done

echo ""
echo "Stopping all challenges"
response=$(curl -s -X POST http://127.0.0.1/api/challenges/stop/all)
if [ "$response" != "All stopped! 🎉" ]; then
    echo "Error stopping all the challenges, got response: $response"
    exit 3
fi
echo "All challenges stopped"

echo ""
echo "Stopping the project"
docker compose down
echo "Project stopped"

echo ""
if [ "$failed" = true ]; then
    echo "❌ TEST FAILED - some auto-solve.sh script failed"
    exit 2
else
    echo "✅ ALL TESTS PASSED"
fi
