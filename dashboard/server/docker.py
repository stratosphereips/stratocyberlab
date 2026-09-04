import subprocess
import sys


def _compose_command(file: str, project_name: str = None) -> list[str]:
    command = ['docker-compose', '-f', file]
    if project_name:
        command.extend(['--project-name', project_name])
    return command


def start_compose(dir: str, project_name: str = None):
    file = f"{dir}/docker-compose.yml"
    command = _compose_command(file, project_name)

    # Starting an already-built plugin must work offline. In particular, avoid
    # asking registries for base-image metadata on every stop/start cycle.
    result = subprocess.run(
        [*command, 'up', '-d', '--no-build'],
        stdout=sys.stdout,
        stderr=sys.stderr
    )
    if result.returncode == 0:
        return

    # A newly installed plugin might not have a local image yet. Build only as
    # a fallback, after the cache-only start proves insufficient.
    result = subprocess.run(
        [*command, 'up', '-d', '--build'],
        stdout=sys.stdout,
        stderr=sys.stderr
    )
    if result.returncode != 0:
        raise Exception("Error doing docker-compose up")


def stop_compose(dir: str, project_name: str = None):
    file = f"{dir}/docker-compose.yml"

    result = subprocess.run(
        [*_compose_command(file, project_name), 'down'],
        stdout=sys.stdout,
        stderr=sys.stderr
    )
    if result.returncode != 0:
        raise Exception("Error doing docker-compose down")


def is_up(dir: str, project_name: str = None) -> bool:
    file = f"{dir}/docker-compose.yml"
    command = _compose_command(file, project_name)

    result = subprocess.run(
        [*command, 'ps', '--services', '--filter', 'status=running'],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        raise Exception("Error reading all services")

    all_healthy = set(result.stdout.strip().split())
    if len(all_healthy) == 0:
        # if not a single container is running, we can directly say it's down
        return False

    result = subprocess.run(
        [*command, 'ps', '--services'],
        capture_output=True, text=True
    )
    if result.returncode != 0:
        raise Exception("Error reading all services")
    all_services = set(result.stdout.strip().split())

    # all running containers must be equal to all defined services
    return all_services == all_healthy
