"""Optional Ollama lifecycle checks. All Docker and model calls are mocked."""

import asyncio
import csv
import json
from pathlib import Path
import sys
import unittest
from unittest.mock import AsyncMock, patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'dashboard' / 'server'))

import app as dashboard  # noqa: E402  # pylint: disable=wrong-import-position
import ollama_runtime as runtime  # noqa: E402  # pylint: disable=wrong-import-position


def container(running=False, legacy=False):
    return {'Id': 'ollama-id', 'State': {'Running': running}, 'Config': {
        'Image': runtime.IMAGE, 'Labels': {'com.docker.compose.service': 'ollama'} if legacy else {
            runtime.LABEL: 'ollama'}}}


class RuntimeTests(unittest.IsolatedAsyncioTestCase):
    """Check containment, storage, retries and migration without a Docker daemon."""

    def setUp(self):
        self.manager = runtime.OllamaRuntime()
        self.docker = self.enterContext(patch.object(runtime, '_docker', AsyncMock(return_value='')))
        self.local_models = self.enterContext(patch.object(
            runtime.llm, 'list_local_models', AsyncMock(return_value=[])))

    async def test_absent_service_is_stopped_and_does_not_pull(self):
        state = await self.manager.status()
        self.assertEqual(state, {'status': 'stopped', 'busy': False, 'running': False, 'error': ''})
        self.assertEqual(self.docker.await_count, 1)
        self.local_models.assert_not_awaited()

    async def test_host_mount_paths_are_preserved_as_one_csv_field(self):
        for source in ('/home/student/SCL/ollama', '/host_mnt/c/Users/A Student/SCL/ollama',
                       'C:\\Users\\A Student\\SCL\\ollama', '/Users/student/SCL, "lab"/ollama'):
            with self.subTest(source=source):
                self.docker.return_value = json.dumps([{'Mounts': [
                    {'Destination': '/ollama', 'Type': 'bind', 'Source': source}]}])
                fields = next(csv.reader([await runtime._model_mount()]))
                self.assertEqual(fields, ['type=bind', f'source={source}', 'target=/root/.ollama'])

    async def test_missing_storage_fails_before_pulling_or_creating(self):
        self.docker.side_effect = ['', json.dumps([{'Mounts': []}])]
        self.manager.reserve('start')
        await self.manager.run('start')
        self.assertIn('storage mount is missing', self.manager.error)
        self.assertFalse(self.manager.phase)
        self.assertEqual(self.docker.await_count, 2)

    async def test_start_pulls_only_if_missing_and_preserves_containment(self):
        for cached in (False, True):
            with self.subTest(cached=cached):
                self.docker.reset_mock()
                self.docker.return_value = 'image-id' if cached else ''
                with patch.object(runtime, '_container', AsyncMock(side_effect=[None, container()])), \
                        patch.object(runtime, '_model_mount', AsyncMock(return_value='type=bind,source=/SCL/ollama,target=/root/.ollama')):
                    self.manager.reserve('start')
                    await self.manager.run('start')
                self.assertEqual(self.manager.error, '')
                calls = [call.args for call in self.docker.await_args_list]
                self.assertEqual(('image', 'pull', runtime.IMAGE) in calls, not cached)
                create = next(args for args in calls if args[:2] == ('container', 'create'))
                self.assertEqual(create[create.index('--name') + 1], 'scl-ollama')
                self.assertEqual(create[create.index('--ip') + 1], '172.20.0.100')
                self.assertEqual(create[create.index('--network') + 1], 'playground-net')
                self.assertEqual(create[create.index('--restart') + 1], 'on-failure')
                self.assertEqual(create[-1], runtime.IMAGE)
                for forbidden in ('--privileged', '--publish', '-p', '--cap-add', '--pid', '--volume'):
                    self.assertNotIn(forbidden, create)
                self.assertEqual(create.count('--mount'), 1)
                self.assertNotIn('docker.sock', ' '.join(create))
                self.assertNotIn('com.docker.compose', ' '.join(create))
                self.assertIn(('container', 'start', 'ollama-id'), calls)

    async def test_failed_pull_is_visible_and_can_be_retried(self):
        self.docker.side_effect = ['', RuntimeError('Registry unavailable')]
        with patch.object(runtime, '_container', AsyncMock(return_value=None)), \
                patch.object(runtime, '_model_mount', AsyncMock(return_value='mount')):
            self.assertTrue(self.manager.reserve('start'))
            await self.manager.run('start')
            state = await self.manager.status()
        self.assertEqual(state['error'], 'Registry unavailable')
        self.assertFalse(state['busy'])
        self.assertTrue(self.manager.reserve('start'))
        self.assertEqual(self.manager.error, '')

    async def test_legacy_stop_removes_container_but_never_model_storage(self):
        old = container(running=True, legacy=True)
        self.docker.side_effect = ['ollama-id', json.dumps([old]), '', '']
        self.manager.reserve('stop')
        await self.manager.run('stop')
        self.assertEqual(self.manager.error, '')
        self.assertEqual(self.docker.await_args_list[-2].args,
                         ('container', 'stop', '--time', '10', 'ollama-id'))
        self.assertEqual(self.docker.await_args_list[-1].args, ('container', 'rm', 'ollama-id'))

    async def test_unrelated_container_is_not_started_or_removed(self):
        other = container()
        other['Config']['Labels'] = {}
        for action in ('start', 'stop'):
            self.docker.reset_mock()
            self.docker.side_effect = ['ollama-id', json.dumps([other])]
            self.manager.reserve(action)
            await self.manager.run(action)
            self.assertIn('unmanaged container', self.manager.error)
            self.assertEqual(self.docker.await_count, 2)

    async def test_existing_running_container_does_not_pull_or_restart(self):
        with patch.object(runtime, '_container', AsyncMock(return_value=container(running=True))):
            self.manager.reserve('start')
            await self.manager.run('start')
        self.docker.assert_not_awaited()
        self.local_models.assert_awaited_once()

    async def test_busy_status_is_available_during_pull_and_blocks_overlap(self):
        self.assertTrue(self.manager.reserve('start'))
        self.manager.phase = 'pulling'
        state = await self.manager.status()
        self.assertTrue(state['busy'])
        self.assertEqual(state['status'], 'pulling')
        self.assertFalse(self.manager.reserve('stop'))
        self.docker.assert_not_awaited()

    async def test_routes_queue_fixed_actions_and_reject_cross_origin_form_posts(self):
        client = dashboard.app.test_client()
        with patch.object(dashboard, 'ollama_runtime', self.manager), \
                patch.object(dashboard.app, 'add_background_task') as queue:
            response = await client.post('/api/llm/ollama/start')
            self.assertEqual(response.status_code, 415)
            queue.assert_not_called()
            response = await client.post('/api/llm/ollama/start', json={})
            self.assertEqual(response.status_code, 202)
            self.assertTrue((await response.get_json())['busy'])
            queue.assert_called_once_with(self.manager.run, 'start')
            response = await client.post('/api/llm/ollama/stop', json={})
            self.assertEqual(response.status_code, 409)
            response = await client.post('/api/llm/ollama/arbitrary', json={})
            self.assertEqual(response.status_code, 405)  # Static catch-all only accepts GET.
            queue.assert_called_once()

    async def test_readiness_failure_is_visible_and_leaves_stop_available(self):
        self.local_models.side_effect = ConnectionError('Starting')
        with patch.object(runtime, '_container', AsyncMock(return_value=container(running=True))), \
                patch.object(runtime.asyncio, 'sleep', AsyncMock()):
            self.manager.reserve('start')
            await self.manager.run('start')
            state = await self.manager.status()
        self.assertTrue(state['running'])
        self.assertFalse(state['busy'])
        self.assertIn('not responding', state['error'])
        self.assertTrue(self.manager.reserve('stop'))

    async def test_state_keeps_external_models_available_when_stopped(self):
        client = dashboard.app.test_client()
        with patch.object(dashboard, 'ollama_runtime', self.manager), \
                patch.object(dashboard.llm_store, 'get_selection', return_value={
                    'current_model': 'external', 'current_external_id': 1}), \
                patch.object(dashboard.llm_store, 'list_models', return_value=[{'id': 1}]):
            response = await client.get('/api/llm/state')
        state = await response.get_json()
        self.assertEqual(response.status_code, 200)
        self.assertEqual(state['external_models'], [{'id': 1}])
        self.assertEqual(state['models'], [])
        self.assertEqual(state['local_error'], '')
        self.local_models.assert_not_awaited()

    async def test_graceful_shutdown_removes_ollama_and_continues_other_cleanup(self):
        for docker_error in (None, RuntimeError('Docker unavailable')):
            with self.subTest(docker_error=docker_error):
                self.docker.reset_mock()
                self.docker.side_effect = docker_error
                with patch.object(dashboard, 'ollama_runtime', self.manager), \
                        patch.object(runtime, '_container', AsyncMock(return_value=container(running=True))), \
                        patch.object(dashboard, 'plugins_stop_all', AsyncMock()) as plugins, \
                        patch.object(dashboard, 'classes_stop_all', AsyncMock()) as classes, \
                        patch.object(dashboard, 'challenges_stop_all', AsyncMock()) as challenges, \
                        patch.object(dashboard, 'eprint') as log:
                    await dashboard.shutdown()
                plugins.assert_awaited_once()
                classes.assert_awaited_once()
                challenges.assert_awaited_once()
                self.docker.assert_any_await('container', 'stop', '--time', '10', 'ollama-id')
                if docker_error:
                    log.assert_any_call('Error stopping Ollama during shutdown: Docker unavailable')
                else:
                    self.docker.assert_any_await('container', 'rm', 'ollama-id')

    async def test_quart_cancels_startup_before_shutdown_cleanup(self):
        started = asyncio.Event()
        events = []

        async def pending_start():
            started.set()
            try:
                await asyncio.Event().wait()
            finally:
                events.append('startup cancelled')

        async def cleanup_command(*args, **_kwargs):
            events.append(args[:2])
            return ''

        self.docker.side_effect = cleanup_command
        with patch.object(dashboard, 'ollama_runtime', self.manager), \
                patch.object(self.manager, '_start', pending_start), \
                patch.object(runtime, '_container', AsyncMock(return_value=container(running=True))), \
                patch.object(dashboard, 'plugins_stop_all', AsyncMock()), \
                patch.object(dashboard, 'classes_stop_all', AsyncMock()), \
                patch.object(dashboard, 'challenges_stop_all', AsyncMock()), \
                patch.object(dashboard, 'eprint'), \
                patch.object(dashboard.app, 'shutdown_event', asyncio.Event(), create=True), \
                patch.dict(dashboard.app.config, {'BACKGROUND_TASK_SHUTDOWN_TIMEOUT': 0.01}):
            self.manager.reserve('start')
            dashboard.app.add_background_task(self.manager.run, 'start')
            await started.wait()
            await dashboard.app.shutdown()
        self.assertEqual(events, ['startup cancelled', ('container', 'stop'), ('container', 'rm')])
        self.assertFalse(self.manager.phase)


class DockerCommandTests(unittest.IsolatedAsyncioTestCase):
    """Verify the subprocess boundary without executing Docker."""

    async def test_timeout_kills_and_reaps_child(self):
        process = AsyncMock()
        process.returncode = None
        process.kill = unittest.mock.Mock()
        process.communicate.side_effect = [TimeoutError(), (b'', b'')]
        with patch.object(asyncio, 'create_subprocess_exec', AsyncMock(return_value=process)):
            with self.assertRaises(TimeoutError):
                await runtime._docker('image', 'pull', runtime.IMAGE)
        process.kill.assert_called_once()
        self.assertEqual(process.communicate.await_count, 2)


if __name__ == '__main__':
    unittest.main()
