"""Manage the optional local model service with fixed Docker configuration."""

import asyncio
import csv
import io
import json

import llm

IMAGE = 'ollama/ollama:0.34.0'
NAME = 'scl-ollama'
NETWORK = 'playground-net'
ADDRESS = '172.20.0.100'
LABEL = 'org.stratocyberlab.service'


async def _docker(*args, timeout=30):
    """Run argument arrays, never a shell; bound and reap every child process."""
    process = await asyncio.create_subprocess_exec(
        'docker', *args, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE)
    try:
        stdout, stderr = await asyncio.wait_for(process.communicate(), timeout)
    except (TimeoutError, asyncio.CancelledError):
        if process.returncode is None:
            process.kill()
        await process.communicate()
        raise
    if process.returncode:
        raise RuntimeError(stderr.decode(errors='replace').strip() or 'Docker command failed.')
    return stdout.decode().strip()


async def _container():
    ids = await _docker('container', 'ls', '--all', '--filter', f'name=^/{NAME}$', '--quiet')
    if not ids:
        return None
    container = json.loads(await _docker('container', 'inspect', ids))[0]
    config = container['Config']
    labels = config.get('Labels') or {}
    # Accept the former base Compose service for upgrades, but never take over
    # an unrelated container just because it has the same name.
    owned = labels.get(LABEL) == 'ollama' or labels.get('com.docker.compose.service') == 'ollama'
    if not owned or config.get('Image') != IMAGE:
        raise RuntimeError('The name scl-ollama is occupied by an unmanaged container.')
    return container


async def _model_mount():
    dashboard = json.loads(await _docker('container', 'inspect', 'scl-dashboard'))[0]
    for mount in dashboard.get('Mounts', []):
        if mount['Destination'] == '/ollama' and mount['Type'] == 'bind':
            # Docker Desktop supplies its own daemon-side path. CSV quoting
            # preserves spaces, commas and Windows paths in --mount arguments.
            output = io.StringIO()
            csv.writer(output, lineterminator='').writerow(
                ['type=bind', f'source={mount["Source"]}', 'target=/root/.ollama'])
            return output.getvalue()
    raise RuntimeError('Ollama storage mount is missing. Recreate the dashboard with the updated docker-compose.yml.')


class OllamaRuntime:
    """Serialize lifecycle requests while exposing progress to every browser."""

    def __init__(self):
        self.phase = ''
        self.error = ''

    def reserve(self, action):
        if self.phase:
            return False
        self.phase = 'starting' if action == 'start' else 'stopping'
        self.error = ''
        return True

    async def status(self):
        if self.phase:
            return {'status': self.phase, 'busy': True, 'running': False, 'error': ''}
        try:
            container = await asyncio.wait_for(_container(), timeout=3)
            running = bool(container and container['State']['Running'])
            return {'status': 'running' if running else 'stopped', 'busy': False,
                    'running': running, 'error': self.error}
        except Exception as exc:
            return {'status': 'unavailable', 'busy': False, 'running': False,
                    'error': str(exc) or 'Docker did not respond in time. Check Docker is running.'}

    async def run(self, action):
        self.error = ''
        try:
            if action == 'start':
                await self._start()
            else:
                container = await _container()
                if container:
                    await _docker('container', 'stop', '--time', '10', container['Id'])
                    # Removing the stopped container releases the Compose network.
                    # No volume removal: all downloaded models remain on the host.
                    await _docker('container', 'rm', container['Id'])
        except Exception as exc:
            self.error = str(exc) or 'Docker operation timed out. Check Docker and retry.'
        finally:
            self.phase = ''

    async def _start(self):
        container = await _container()
        if container is None:
            mount = await _model_mount()
            images = await _docker('image', 'ls', '--quiet', IMAGE)
            if not images:
                self.phase = 'pulling'
                await _docker('image', 'pull', IMAGE, timeout=7200)
            self.phase = 'starting'
            await _docker(
                'container', 'create', '--name', NAME, '--label', f'{LABEL}=ollama',
                '--network', NETWORK, '--network-alias', 'ollama', '--ip', ADDRESS,
                '--restart', 'on-failure', '--mount', mount,
                '--health-cmd', 'ollama --version || exit 1', '--health-interval', '30s',
                '--health-timeout', '10s', '--health-retries', '3', '--health-start-period', '10s',
                IMAGE)
            container = await _container()
        if not container['State']['Running']:
            await _docker('container', 'start', container['Id'])
        # A running process is not necessarily ready to list or download models.
        for _ in range(60):
            try:
                await asyncio.wait_for(llm.list_local_models(), timeout=2)
                return
            except Exception:
                await asyncio.sleep(1)
        raise RuntimeError('Ollama started but is not responding. Check its container logs or stop and retry.')


runtime = OllamaRuntime()
