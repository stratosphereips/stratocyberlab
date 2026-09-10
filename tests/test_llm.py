"""Assistant integration checks with a temporary database and mocked providers.

Run: python -m unittest discover -s tests -p test_llm.py
"""

import io
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import AsyncMock, patch
from urllib.error import HTTPError, URLError

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'dashboard' / 'server'))

import app as dashboard  # noqa: E402  # pylint: disable=wrong-import-position
import db  # noqa: E402  # pylint: disable=wrong-import-position
import llm  # noqa: E402  # pylint: disable=wrong-import-position
import llm_store  # noqa: E402  # pylint: disable=wrong-import-position


class AssistantTests(unittest.IsolatedAsyncioTestCase):
    """Exercise public routes and ensure saved credentials remain private."""

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.enterContext(patch.object(db, 'DATABASE', str(Path(self.temp.name) / 'test.sqlite3')))
        llm_store.init_tables()
        self.client = dashboard.app.test_client()
        self.local_list = self.enterContext(patch.object(
            llm, 'list_local_models', AsyncMock(return_value=[{'name': 'local:test', 'size': 42}])))
        self.config = {'provider': 'openai', 'base_url': 'https://api.example.test/v1/',
                       'model': 'example-chat', 'api_key': 'test-secret-never-return-this'}

    async def create_model(self, **overrides):
        response = await self.client.post('/api/llm/external-models', json=self.config | overrides)
        self.assertEqual(response.status_code, 201)
        self.assertNotIn(self.config['api_key'], await response.get_data(as_text=True))
        return (await response.get_json())['id']

    async def test_save_edit_restart_selection_and_delete(self):
        model_id = await self.create_model()
        response = await self.client.put('/api/llm/model', json={'external_id': model_id})
        self.assertEqual(response.status_code, 200)
        llm_store.init_tables()  # Startup is idempotent and preserves selection/configuration.
        state = await (await self.client.get('/api/llm/state')).get_json()
        self.assertEqual(state['current_external_id'], model_id)
        self.assertEqual(state['external_models'], [{'id': model_id, 'provider': 'openai',
                                                     'base_url': 'https://api.example.test/v1', 'model': 'example-chat'}])
        self.assertNotIn(self.config['api_key'], json.dumps(state))

        response = await self.client.put(f'/api/llm/external-models/{model_id}',
                                         json=self.config | {'api_key': '', 'model': 'changed-model'})
        self.assertEqual(response.status_code, 200)
        self.assertEqual(llm_store.get_model(model_id)['api_key'], self.config['api_key'])
        self.assertEqual(llm.get_current_model(), 'changed-model')
        await self.client.put(f'/api/llm/external-models/{model_id}',
                              json=self.config | {'api_key': 'replacement-secret'})
        self.assertEqual(llm_store.get_model(model_id)['api_key'], 'replacement-secret')
        response = await self.client.delete(f'/api/llm/external-models/{model_id}')
        self.assertEqual(response.status_code, 204)
        self.assertEqual(llm_store.get_selection(), {'current_model': '', 'current_external_id': None})
        self.assertIsNone(llm_store.get_model(model_id))

    async def test_external_chat_works_without_ollama_and_uses_saved_key(self):
        model_id = await self.create_model()
        self.local_list.side_effect = ConnectionError('Ollama stopped')
        await self.client.put('/api/llm/model', json={'external_id': model_id})
        response = await self.client.get('/api/llm/state')
        self.assertEqual(response.status_code, 200)
        self.assertTrue((await response.get_json())['local_error'])
        messages = [{'role': 'user', 'content': 'Explain DNS'}]
        upstream = io.BytesIO(json.dumps({'choices': [{'message': {'content': 'DNS answer'}}]}).encode())
        with patch.object(llm.urllib_request, 'urlopen', return_value=upstream) as outgoing:
            response = await self.client.post('/api/llm/chat', json=messages)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(await response.get_json(), messages + [{'role': 'assistant', 'content': 'DNS answer'}])
        request = outgoing.call_args.args[0]
        self.assertEqual(request.full_url, 'https://api.example.test/v1/chat/completions')
        self.assertEqual(request.get_header('Authorization'), 'Bearer ' + self.config['api_key'])
        payload = json.loads(request.data)
        self.assertEqual(payload['model'], self.config['model'])
        self.assertEqual(payload['messages'], [llm.INIT_MESSAGES[0]] + messages)
        self.assertNotIn(self.config['api_key'], request.data.decode())

    async def test_upstream_errors_and_echoed_keys_are_redacted(self):
        model_id = await self.create_model()
        llm_store.select_model(external_id=model_id)
        secret = self.config['api_key']
        errors = [HTTPError('https://example.test', 401, secret, {}, io.BytesIO(secret.encode())),
                  URLError(secret), TimeoutError(secret)]
        for error in errors:
            with self.subTest(error=type(error).__name__), \
                    patch.object(llm.urllib_request, 'urlopen', side_effect=error), \
                    patch('sys.stderr', new_callable=io.StringIO) as logs:
                response = await self.client.post('/api/llm/chat', json=[])
                self.assertEqual(response.status_code, 400)
                self.assertNotIn(secret, await response.get_data(as_text=True))
                self.assertNotIn(secret, logs.getvalue())
        upstream = io.BytesIO(json.dumps({'choices': [{'message': {'content': secret}}]}).encode())
        with patch.object(llm.urllib_request, 'urlopen', return_value=upstream):
            response = await self.client.post('/api/llm/chat', json=[])
        self.assertEqual((await response.get_json())[-1]['content'], '[redacted]')

    async def test_local_selection_chat_and_removal(self):
        await self.create_model(model='local:test')  # Same name must not confuse selection.
        response = await self.client.put('/api/llm/model', json={'name': 'local:test'})
        self.assertEqual(response.status_code, 200)
        self.assertIsNone(llm_store.get_selection()['current_external_id'])
        with patch.object(llm.client, 'chat', AsyncMock(return_value={'message': {'content': 'Local reply'}})):
            response = await self.client.post('/api/llm/chat', json=[])
        self.assertEqual((await response.get_json())[-1]['content'], 'Local reply')
        with patch.object(llm.client, 'delete', AsyncMock()):
            response = await self.client.delete('/api/llm/models/local:test')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(llm.get_current_model(), '')
        self.assertEqual(len(llm_store.list_models()), 1)

    async def test_validation_does_not_echo_configuration_or_accept_missing_models(self):
        for invalid in ({'api_key': ''}, {'provider': 'unknown'}, {'model': ''},
                        {'base_url': 'not a URL'}, {'api_key': 'secret\nheader'}):
            response = await self.client.post('/api/llm/external-models', json=self.config | invalid)
            self.assertEqual(response.status_code, 400)
            self.assertNotIn(self.config['api_key'], await response.get_data(as_text=True))
        for selection in ({'external_id': 999}, {'external_id': 'wrong'}, {'name': 'local'}):
            response = await self.client.put('/api/llm/model', json=selection)
            self.assertEqual(response.status_code, 400)
        response = await self.client.post('/api/llm/chat', json={'messages': []})
        self.assertEqual(response.status_code, 400)

    async def test_terminal_context_keeps_history_and_formats_both_providers(self):
        snapshot = {'text': '  curl: connection refused\n<script>example</script>',
                    'captured_at': '2026-09-10T12:00:00.000Z', 'truncated': True}
        question = {'role': 'user', 'content': 'Why?', 'terminal_context': snapshot}
        messages = [question]
        await self.client.put('/api/llm/model', json={'name': 'local:test'})
        with patch.object(llm.client, 'chat', AsyncMock(
                return_value={'message': {'content': 'Local reply'}})) as local_chat:
            response = await self.client.post('/api/llm/chat', json=messages)
        self.assertEqual(response.status_code, 200)
        history = await response.get_json()
        self.assertEqual(history[0], question)
        local_input = local_chat.call_args.kwargs['messages'][-1]
        self.assertEqual(set(local_input), {'role', 'content'})
        self.assertEqual(local_input['role'], 'user')
        self.assertIn('User question:\nWhy?', local_input['content'])
        self.assertIn('connection refused', local_input['content'])
        self.assertNotIn(snapshot['text'], llm.INIT_MESSAGES[0]['content'])

        model_id = await self.create_model()
        llm_store.select_model(external_id=model_id)
        # A subsequent question without a new attachment retains the old snapshot.
        history.append({'role': 'user', 'content': 'Explain that previous error again.'})
        upstream = io.BytesIO(json.dumps({'choices': [{'message': {'content': 'External reply'}}]}).encode())
        with patch.object(llm.urllib_request, 'urlopen', return_value=upstream) as outgoing:
            response = await self.client.post('/api/llm/chat', json=history)
        self.assertEqual(response.status_code, 200)
        self.assertEqual((await response.get_json())[:-1], history)
        payload = json.loads(outgoing.call_args.args[0].data)
        self.assertEqual(payload['messages'][1], local_input)
        self.assertEqual(payload['messages'][-1], history[-1])
        self.assertEqual(messages, [question])

    async def test_invalid_terminal_attachments_are_rejected_before_provider_calls(self):
        snapshot = {'text': 'valid', 'captured_at': '2026-09-10T12:00:00Z', 'truncated': False}
        invalid_contexts = [None, 'text', snapshot | {'text': 'a\n' * 100},
                            snapshot | {'text': '😀' * 2501}, snapshot | {'truncated': 'false'},
                            snapshot | {'captured_at': 'invalid'}, snapshot | {'text': 123}]
        with patch.object(llm.client, 'chat', AsyncMock()) as local_chat:
            for context in invalid_contexts:
                response = await self.client.post('/api/llm/chat', json=[
                    {'role': 'user', 'content': 'Why?', 'terminal_context': context}])
                self.assertEqual(response.status_code, 400)
            response = await self.client.post('/api/llm/chat', json=[
                {'role': 'assistant', 'content': 'Reply', 'terminal_context': snapshot}])
            self.assertEqual(response.status_code, 400)
            local_chat.assert_not_called()


if __name__ == '__main__':
    unittest.main()
