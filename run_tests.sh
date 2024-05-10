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
docker compose up -d --build --force-recreate

# Wait for the dashboard to initialize
sleep 2

LABUSER='root'
LABPASS='ByteThem123'
LABHOST='172.20.0.2'

CHALLENGES_DIR="challenges"

failed=false
for chal_dir in "$CHALLENGES_DIR"/*/; do
    if [[ "$chal_dir" == "challenges/template/" ]]; then
        # skip template
        continue
    fi

    echo ""
    echo "Testing $chal_dir:"

    solve_script="$chal_dir/auto-solve.sh"
    if [ -f "$solve_script" ]; then
        # Copy auto-solve script into /tmp dir in hackerlab container
        # We use ssh instead of docker exec to test also the SSH connection
        sshpass -p "$LABPASS" scp -O \
                -o LogLevel=error \
                -o UserKnownHostsFile=/dev/null \
                -o StrictHostKeyChecking=no \
                $solve_script \
                $LABUSER@$LABHOST:/tmp/auto-solve.sh
        # Run the auto-solve script from within the hackerlab container
        sshpass -p "$LABPASS" ssh \
        -o LogLevel=error \
        -o UserKnownHostsFile=/dev/null \
        -o StrictHostKeyChecking=no \
        $LABUSER@$LABHOST \
        /tmp/auto-solve.sh

        retVal=$?
        if [ $retVal -ne 0 ]; then
            failed=true
        fi

    else
        echo "WARNING - missing $solve_script script"
    fi
done

echo ""
if [ "$failed" = true ]; then
    echo "❌ TEST FAILED - some auto-solve.sh script fialed"
    exit 2
else
    echo "✅ ALL TESTS PASSED"
fi
