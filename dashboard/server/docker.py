import subprocess
import sys


def start_compose(dir: str):
    file = f"{dir}/docker-compose.yml"

    # Starting an already-built plugin must work offline. In particular, avoid
    # asking registries for base-image metadata on every stop/start cycle.
    result = subprocess.run(
        ['docker-compose', '-f', file, 'up', '-d', '--no-build'],
        stdout=sys.stdout,
        stderr=sys.stderr
    )
    if result.returncode == 0:
        return

    # A newly installed plugin might not have a local image yet. Build only as
    # a fallback, after the cache-only start proves insufficient.
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
