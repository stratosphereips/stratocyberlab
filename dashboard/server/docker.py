import subprocess
import sys

def start_compose(dir: str):
    file = f"{dir}/docker-compose.yml"

    result = subprocess.run(
        ['docker-compose', '-f', file, 'up', '-d', '--build'],
        stdout=sys.stdout,
        stderr=sys.stderr
    )
    if result.returncode != 0:
        raise Exception("Error doing docker-compose up")

def stop_compose(dir: str):
    file = f"{dir}/docker-compose.yml"

    result = subprocess.run(
        ['docker-compose', '-f', file, 'down'],
        stdout=sys.stdout,
        stderr=sys.stderr
    )
    if result.returncode != 0:
        raise Exception("Error doing docker-compose down")

def is_up(dir: str) -> bool:
    file = f"{dir}/docker-compose.yml"

    result = subprocess.run(
        f"docker-compose -f {file} ps --services --filter 'status=running'",
        shell=True, capture_output=True, text=True
    )
    if result.returncode != 0:
        raise Exception("Error reading all services")

    all_healthy = set(result.stdout.strip().split())
    if len(all_healthy) == 0:
        # if not a single container is running, we can directly say it's down
        return False

    result = subprocess.run(
        ['docker-compose', '-f', file, 'ps', "--services"],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        raise Exception("Error reading all services")
    all_services = set(result.stdout.strip().split())

    # all running containers must be equal to all defined services
    return all_services == all_healthy

