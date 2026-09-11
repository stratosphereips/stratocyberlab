"""Persistence checks use temporary databases; no lab containers are started."""

import asyncio
from contextlib import closing
from pathlib import Path
import sqlite3
import sys
import tempfile
import unittest
from unittest.mock import AsyncMock, patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'dashboard' / 'server'))

import app as dashboard  # pylint: disable=wrong-import-position
import db  # pylint: disable=wrong-import-position
import llm  # pylint: disable=wrong-import-position
import llm_store  # pylint: disable=wrong-import-position
import migrations  # pylint: disable=wrong-import-position


class PersistenceTests(unittest.IsolatedAsyncioTestCase):
    """Exercise upgrades, atomic refresh/reset, and browser-independent progress."""

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.path = Path(self.temp.name) / 'db.sqlite3'
        self.enterContext(patch.object(db, 'DATABASE', str(self.path)))
        self.config = {'provider': 'custom', 'base_url': 'https://example.test/v1',
                       'model': 'test-model', 'api_key': 'private-test-key'}
        self.client = dashboard.app.test_client()

    def query(self, sql):
        with closing(db.get_db()) as conn:
            return conn.execute(sql).fetchall()

    def bootstrap(self):
        # Discovery only reads repository files. Runtime Docker operations are not called.
        dashboard.init(*(str(ROOT / folder) for folder in ('challenges', 'classes', 'campaigns', 'plugins')))

    def seed(self):
        migrations.migrate()
        db.insert_challenge_data('test', 'Test', 'Description', 'easy', '/test', [])
        db.insert_task_data('test', 'task', 'Task', 'Description', 'flag', 0)
        db.write_new_solve('local', 'test', 'task')
        model_id = llm_store.save_model(self.config)
        llm_store.select_model(external_id=model_id)
        return model_id

    def test_fresh_and_repeated_startup_refreshes_real_content(self):
        self.bootstrap()
        before = {table: self.query(f'SELECT COUNT(*) FROM {table}') for table in db.CONTENT_TABLES}
        self.assertGreater(before['tasks'][0][0], 0)
        challenge, task = self.query('SELECT challenge_id, task_id FROM tasks LIMIT 1')[0]
        db.write_new_solve('local', challenge, task)
        model_id = llm_store.save_model(self.config)
        llm_store.select_model(external_id=model_id)
        with closing(db.get_db()) as conn, conn:
            conn.execute("UPDATE challenges SET challenge_name = 'stale metadata'")
        self.bootstrap()
        self.assertEqual(before, {table: self.query(f'SELECT COUNT(*) FROM {table}') for table in db.CONTENT_TABLES})
        self.assertEqual(self.query("SELECT COUNT(*) FROM challenges WHERE challenge_name = 'stale metadata'"), [(0,)])
        self.assertEqual(self.query('SELECT COUNT(*) FROM task_solves'), [(1,)])
        self.assertEqual(llm_store.get_selection()['current_external_id'], model_id)
        self.assertFalse((self.path.parent / 'backups').exists())

    def test_legacy_upgrade_merges_sessions_and_backs_up(self):
        db.init_db_tables()
        llm_store.init_tables()
        db.write_new_solve('browser-a', 'test', 'task')
        db.write_new_solve('browser-b', 'test', 'task')
        db.write_new_solve('browser-b', 'test', 'task-2')
        model_id = llm_store.save_model(self.config)
        llm_store.select_model(external_id=model_id)
        migrations.migrate()
        self.assertEqual(self.query('SELECT session, COUNT(*) FROM task_solves GROUP BY session'), [('local', 2)])
        self.assertEqual(llm_store.get_model(model_id)['api_key'], self.config['api_key'])
        backups = list((self.path.parent / 'backups').glob('*.sqlite3'))
        self.assertEqual(len(backups), 1)
        with closing(sqlite3.connect(backups[0])) as backup:
            self.assertEqual(backup.execute('PRAGMA user_version').fetchone()[0], 0)
            self.assertEqual(backup.execute('SELECT COUNT(*) FROM task_solves').fetchone()[0], 3)
        migrations.migrate()
        self.assertEqual(len(list((self.path.parent / 'backups').glob('*.sqlite3'))), 1)

    def test_upgrade_from_version_one(self):
        with closing(db.get_db()) as conn, conn:
            migrations.initial_schema(conn)
            conn.execute('PRAGMA user_version = 1')
        db.write_new_solve('old-browser', 'test', 'task')
        migrations.migrate()
        self.assertEqual(self.query('PRAGMA user_version'), [(len(migrations.MIGRATIONS),)])
        self.assertEqual(self.query('SELECT session FROM task_solves'), [('local',)])

    def test_failed_migration_rolls_back_schema_data_and_version(self):
        self.seed()

        def broken(conn):
            conn.execute('CREATE TABLE unfinished (id INTEGER)')
            conn.execute('DELETE FROM task_solves')
            raise RuntimeError('simulated migration failure')

        with patch.object(migrations, 'MIGRATIONS', migrations.MIGRATIONS + (broken,)):
            with self.assertRaisesRegex(RuntimeError, 'simulated'):
                migrations.migrate()
        self.assertEqual(self.query('PRAGMA user_version'), [(len(migrations.MIGRATIONS),)])
        self.assertEqual(self.query('SELECT COUNT(*) FROM task_solves'), [(1,)])
        self.assertEqual(self.query("SELECT name FROM sqlite_master WHERE name = 'unfinished'"), [])

    def test_newer_schema_is_refused_without_changes(self):
        self.seed()
        with closing(db.get_db()) as conn:
            conn.execute('PRAGMA user_version = 999')
        before = self.path.read_bytes()
        with self.assertRaisesRegex(RuntimeError, 'newer'):
            migrations.migrate()
        self.assertEqual(before, self.path.read_bytes())

    def test_failed_content_refresh_preserves_previous_metadata(self):
        self.seed()
        with self.assertRaises(RuntimeError):
            with db.refresh_content() as conn:
                db.insert_class_data('new', 'New', '', '', '', '', '', connection=conn)
                raise RuntimeError('invalid repository metadata')
        self.assertEqual(self.query('SELECT challenge_id FROM challenges'), [('test',)])
        self.assertEqual(self.query('SELECT COUNT(*) FROM classes'), [(0,)])
        self.assertEqual(self.query('SELECT COUNT(*) FROM task_solves'), [(1,)])

    async def test_all_reset_scopes_and_validation(self):
        self.seed()
        for invalid in (None, [], {}, {'scope': 'unknown'}):
            response = await self.client.post('/api/state/reset', json=invalid)
            self.assertIn(response.status_code, (400, 415))
        for scope in ('progress', 'ai', 'all'):
            with self.subTest(scope=scope):
                db.write_new_solve('local', 'test', 'task')
                if not llm_store.list_models():
                    llm_store.select_model(external_id=llm_store.save_model(self.config))
                response = await self.client.post('/api/state/reset', json={'scope': scope})
                self.assertEqual(response.status_code, 200)
                self.assertEqual(self.query('SELECT COUNT(*) FROM task_solves'), [(int(scope == 'ai'),)])
                self.assertEqual(len(llm_store.list_models()), int(scope == 'progress'))
                if scope != 'progress':
                    self.assertEqual(llm_store.get_selection(), {'current_model': '', 'current_external_id': None})
                self.assertEqual(self.query('SELECT COUNT(*) FROM tasks'), [(1,)])

    def test_failed_reset_is_atomic(self):
        self.seed()
        with closing(db.get_db()) as conn:
            conn.execute("""CREATE TRIGGER prevent_delete BEFORE DELETE ON llm_external_models
                BEGIN SELECT RAISE(ABORT, 'simulated failure'); END""")
        with self.assertRaises(sqlite3.IntegrityError):
            db.reset_state('all')
        self.assertEqual(self.query('SELECT COUNT(*) FROM task_solves'), [(1,)])
        self.assertIsNotNone(llm_store.get_selection()['current_external_id'])

    async def test_progress_is_shared_by_new_browser_sessions(self):
        self.seed()
        db.reset_state('progress')
        response = await self.client.post('/api/challenges/submit', json={
            'challenge_id': 'test', 'task_id': 'task', 'flag': 'flag'})
        self.assertEqual(response.status_code, 200)
        other_browser = dashboard.app.test_client()
        challenges = await (await other_browser.get('/api/challenges')).get_json()
        self.assertTrue(challenges[0]['tasks'][0]['solved'])

    async def test_reset_refuses_in_flight_chat_then_succeeds(self):
        self.seed()
        started, finish = asyncio.Event(), asyncio.Event()

        async def chat(_body):
            started.set()
            await finish.wait()
            return []

        with patch.object(llm, 'chat_with_llm', AsyncMock(side_effect=chat)):
            pending = asyncio.create_task(self.client.post('/api/llm/chat', json=[]))
            await started.wait()
            try:
                response = await dashboard.app.test_client().post('/api/state/reset', json={'scope': 'all'})
                self.assertEqual(response.status_code, 409)
                self.assertEqual(len(llm_store.list_models()), 1)
            finally:
                finish.set()
                await pending
        response = await self.client.post('/api/state/reset', json={'scope': 'all'})
        self.assertEqual(response.status_code, 200)


if __name__ == '__main__':
    unittest.main()
