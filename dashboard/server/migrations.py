"""Ordered SQLite upgrades. Never modify a released migration; append a new one."""

from contextlib import closing
from datetime import datetime, timezone
from pathlib import Path
import sqlite3
from uuid import uuid4

import db
import llm_store


def initial_schema(conn):
    """Adopt both fresh databases and the original, unversioned schema."""
    db.init_db_tables(conn)
    llm_store.init_tables(conn)


def single_learner(conn):
    """Merge existing browser sessions into one local learner's progress."""
    conn.execute('CREATE TEMP TABLE merged_solves AS SELECT DISTINCT task_id, challenge_id FROM task_solves')
    conn.execute('DELETE FROM task_solves')
    conn.execute("INSERT INTO task_solves SELECT 'local', task_id, challenge_id FROM merged_solves")
    conn.execute('DROP TABLE merged_solves')


MIGRATIONS = (initial_schema, single_learner)


def migrate():
    """Back up existing state, then upgrade all missing versions in one transaction."""
    path = Path(db.DATABASE)
    path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    # SQLite files and backups contain API credentials. Do not expose them via static files.
    path.touch(mode=0o600, exist_ok=True)
    path.chmod(0o600)
    with closing(db.get_db()) as conn:
        version = conn.execute('PRAGMA user_version').fetchone()[0]
        if version > len(MIGRATIONS):
            raise RuntimeError('Dashboard database is newer than this application. Use a newer image or restore a compatible backup.')
        if version == len(MIGRATIONS):
            return
        if conn.execute("SELECT 1 FROM sqlite_master WHERE type = 'table' LIMIT 1").fetchone():
            backup_dir = path.parent / 'backups'
            backup_dir.mkdir(exist_ok=True, mode=0o700)
            timestamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
            backup = backup_dir / f'v{version}-{timestamp}-{uuid4().hex}.sqlite3'
            backup.touch(mode=0o600)
            with closing(sqlite3.connect(backup)) as destination:
                conn.backup(destination)
        with conn:
            conn.execute('BEGIN IMMEDIATE')
            for index in range(version, len(MIGRATIONS)):
                MIGRATIONS[index](conn)
                conn.execute(f'PRAGMA user_version = {index + 1}')
