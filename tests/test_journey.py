"""Class journey checks use temporary databases and class folders; no lab containers are started.

Run: python -m unittest discover -s tests -p test_journey.py
"""

import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'dashboard' / 'server'))

import app as dashboard  # pylint: disable=wrong-import-position
import db  # pylint: disable=wrong-import-position


class JourneyTests(unittest.IsolatedAsyncioTestCase):
    """Exercise locked classes and cover images."""

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.enterContext(patch.object(db, 'DATABASE', str(Path(self.temp.name) / 'db.sqlite3')))
        self.classes = Path(self.temp.name) / 'classes'
        self.add_class('class01', 'class-01', compose=True, cover=True)
        self.add_class('ignore-class02', 'class-02', compose=True)
        self.client = dashboard.app.test_client()

    def add_class(self, folder, class_id, compose=False, cover=False):
        path = self.classes / folder
        path.mkdir(parents=True)
        (path / 'meta.json').write_text(json.dumps({
            'id': class_id, 'name': f'{class_id} name', 'description': 'About <b>it</b>',
            'starting_time': '2026-09-24T14:30:00+02:00', 'google_doc_url': 'https://docs.google.com/document/d/x',
        }))
        if compose:
            (path / 'docker-compose.yml').write_text('services: {}\n')
        if cover:
            (path / 'cover.jpg').write_bytes(b'\xff\xd8\xff\xe0test')

    def bootstrap(self):
        empty = Path(self.temp.name) / 'empty'
        empty.mkdir(exist_ok=True)
        dashboard.init(str(empty), str(self.classes), str(empty), str(empty))

    async def test_unreleased_classes_are_locked_and_cannot_start(self):
        self.bootstrap()
        classes = {c['id']: c for c in await (await self.client.get('/api/classes')).get_json()}
        self.assertEqual(set(classes), {'class-01', 'class-02'})
        self.assertFalse(classes['class-01']['locked'])
        self.assertTrue(classes['class-01']['dir'])
        self.assertTrue(classes['class-01']['has_cover'])
        self.assertTrue(classes['class-02']['locked'])
        self.assertEqual((classes['class-02']['dir'], classes['class-02']['google_doc_url']), ('', ''))
        self.assertFalse(classes['class-02']['has_cover'])
        self.assertNotIn('folder', classes['class-01'])
        response = await self.client.post('/api/classes/start', json={'id': 'class-02'})
        self.assertEqual(response.status_code, 400)
        # Status checks and shutdown cleanup see only startable classes; checked without calling Docker.
        self.assertEqual([c['id'] for c in db.get_classes(only_with_compose=True)], ['class-01'])

    async def test_cover_is_served_only_from_its_class_folder(self):
        self.bootstrap()
        response = await self.client.get('/api/classes/class-01/cover')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content_type, 'image/jpeg')
        for class_id in ('class-02', 'missing', '..', '%2e%2e%2fclass01'):
            with self.subTest(class_id=class_id):
                self.assertEqual((await self.client.get(f'/api/classes/{class_id}/cover')).status_code, 404)

    def test_incomplete_unreleased_class_is_skipped(self):
        (self.classes / 'ignore-draft').mkdir()
        self.bootstrap()
        self.assertEqual([c['id'] for c in db.get_classes()], ['class-01', 'class-02'])

    def test_incomplete_released_class_stops_startup(self):
        (self.classes / 'class03').mkdir()
        with self.assertRaises(FileNotFoundError):
            self.bootstrap()


if __name__ == '__main__':
    unittest.main()
